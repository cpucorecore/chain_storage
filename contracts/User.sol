pragma solidity ^0.5.2;
pragma experimental ABIEncoderV2;

import "./base/Importable.sol";
import "./base/ExternalStorable.sol";
import "./interfaces/storages/IUserStorage.sol";
import "./interfaces/IUser.sol";
import "./interfaces/ISetting.sol";
import "./interfaces/IFile.sol";
import "./interfaces/IHistory.sol";

contract User is Importable, ExternalStorable, IUser {
    using SafeMath for uint256;

    event FileAdded(address indexed owner, string cid); // for User Client
    event FileAddFailed(address indexed owner, string cid); // for User Client
    event FileDeleted(address indexed owner, string cid); // for User Client

    constructor(IResolver _resolver) public Importable(_resolver) {
        setContractName(CONTRACT_USER);
        imports = [
            CONTRACT_SETTING,
            CONTRACT_FILE,
            CONTRACT_HISTORY
        ];
    }

    function Storage() private view returns(IUserStorage) {
        return IUserStorage(getStorage());
    }

    function Setting() private view returns (ISetting) {
        return ISetting(requireAddress(CONTRACT_SETTING));
    }

    function File() private view returns (IFile) {
        return IFile(requireAddress(CONTRACT_FILE));
    }

    function History() private view returns (IHistory) {
        return IHistory(requireAddress(CONTRACT_HISTORY));
    }

    function exist(address addr) external view returns (bool) {
        return Storage().exist(addr);
    }

    function register(address addr, string calldata ext) external onlyAddress(CONTRACT_CHAIN_STORAGE) {
        require(!Storage().exist(addr), contractName.concat(": user exist"));
        require(bytes(ext).length <= Setting().getMaxUserExtLength(), contractName.concat(": user ext too long"));
        Storage().newUser(addr, Setting().getInitSpace(), ext);
    }

    function deRegister(address addr) external onlyAddress(CONTRACT_CHAIN_STORAGE) {
        require(Storage().exist(addr), contractName.concat(": user not exist"));
        require(0 == Storage().getFileNumber(addr), contractName.concat(": files not empty"));
        Storage().deleteUser(addr);
    }

    function getExt(address addr) external view returns (string memory) {
        return Storage().getExt(addr);
    }

    function setExt(address addr, string calldata ext) external onlyAddress(CONTRACT_CHAIN_STORAGE) {
        require(Storage().exist(addr), contractName.concat(": user not exist"));
        require(bytes(ext).length <= Setting().getMaxUserExtLength(), contractName.concat(": user ext too long"));
        Storage().setExt(addr, ext);
    }

    function changeSpace(address addr, uint256 size) external onlyAddress(CONTRACT_CHAIN_STORAGE) {
        require(Storage().exist(addr), contractName.concat(": user not exist"));
        require(size >= Storage().getStorageUsed(addr), contractName.concat(": can not little than storage used"));
        Storage().setStorageTotal(addr, size);
    }

    function getStorageUsed(address addr) external view returns (uint256) {
        return Storage().getStorageUsed(addr);
    }

    function getStorageTotal(address addr) external view returns (uint256) {
        return Storage().getStorageTotal(addr);
    }

    function addFile(address addr, string calldata cid, uint256 size, uint256 duration, string calldata ext) external onlyAddress(CONTRACT_CHAIN_STORAGE) {
        require(size > 0, contractName.concat(": size must > 0"));
        require(bytes(ext).length <= Setting().getMaxUserExtLength(), contractName.concat(": file ext too long"));
        require(bytes(cid).length <= Setting().getMaxCidLength(), contractName.concat(": cid too long"));
        require(!Storage().fileExist(addr, cid), contractName.concat(": file exist"));
        require(Storage().getStorageFree(addr) >= size, contractName.concat(": space not enough"));

        History().addUserAction(addr, IHistory.ActionType.Add, keccak256(bytes(cid)));
        File().addFile(cid, size, addr);
        Storage().addFile(addr, cid, duration, ext, now);
        useStorage(addr, size);
    }

    function callbackFinishAddFile(address owner, address node, string calldata cid) external onlyAddress(CONTRACT_FILE) {
        if(!File().ownerExist(cid, owner)) {
            uint256 size = File().getSize(cid);
            emit FileAdded(owner, cid);
        }
    }

    function callbackFailAddFile(address owner, string calldata cid) external onlyAddress(CONTRACT_NODE) {
        if(!File().ownerExist(cid, owner)) {
            uint256 invalidAddFileCount = Storage().getInvalidAddFileCount(owner);
            Storage().setInvalidAddFileCount(owner, invalidAddFileCount.add(1));
            emit FileAddFailed(owner, cid);
        }
    }

    function deleteFile(address addr, string calldata cid) external onlyAddress(CONTRACT_CHAIN_STORAGE) {
        require(bytes(cid).length <= Setting().getMaxCidLength(), contractName.concat(": cid too long"));
        require(Storage().fileExist(addr, cid), contractName.concat(": file not exist"));

        History().addUserAction(addr, IHistory.ActionType.Delete, keccak256(bytes(cid)));
        Storage().deleteFile(addr, cid);
        uint256 size = File().getSize(cid);
        freeStorage(addr, size);
        File().deleteFile(cid, addr);
    }

    function callbackFinishDeleteFile(address owner, address node, string calldata cid) external onlyAddress(CONTRACT_FILE) {
        uint256 size = File().getSize(cid);
        emit FileDeleted(owner, cid);
    }

    function getFileExt(address addr, string calldata cid) external view returns (string memory) {
        return Storage().getFileExt(addr, cid);
    }

    function setFileExt(address addr, string calldata cid, string calldata ext) external onlyAddress(CONTRACT_CHAIN_STORAGE) {
        require(Storage().exist(addr), contractName.concat(": user not exist"));
        require(Storage().fileExist(addr, cid), contractName.concat(": user have no the file"));
        require(bytes(ext).length <= Setting().getMaxFileExtLength(), contractName.concat(": file ext too long"));
        Storage().setFileExt(addr, cid, ext);
    }

    function getFileDuration(address addr, string calldata cid) external view returns (uint256) {
        return Storage().getFileDuration(addr, cid);
    }

    function setFileDuration(address addr, string calldata cid, uint256 duration) external onlyAddress(CONTRACT_CHAIN_STORAGE) {
        require(Storage().exist(addr), contractName.concat(": user not exist"));
        require(Storage().fileExist(addr, cid), contractName.concat(": user have no the file"));
        Storage().setFileDuration(addr, cid, duration);
    }

    function getCids(address addr, uint256 pageSize, uint256 pageNumber) external view returns(string[] memory, bool) {
        return Storage().getCids(addr, pageSize, pageNumber);
    }

    function getTotalUserNumber() external view returns (uint256) {
        return Storage().getTotalUserNumber();
    }

    function useStorage(address addr, uint256 size) private {
        uint256 used = Storage().getStorageUsed(addr);
        uint256 total = Storage().getStorageTotal(addr);
        require(size > 0 && used.add(size) <= total, contractName.concat(": space not enough"));
        Storage().setStorageUsed(addr, used.add(size));
    }

    function freeStorage(address addr, uint256 size) private {
        uint256 used = Storage().getStorageUsed(addr);
        uint256 total = Storage().getStorageTotal(addr);
        require(size > 0 && size <= used, contractName.concat(": free size can not big than used size"));
        Storage().setStorageUsed(addr, used.sub(size));
    }
}
