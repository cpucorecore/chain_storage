pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import "./base/Importable.sol";
import "./base/ExternalStorable.sol";
import "./interfaces/storages/IUserStorage.sol";
import "./interfaces/IUser.sol";
import "./interfaces/ISetting.sol";
import "./interfaces/IFile.sol";

contract User is Importable, ExternalStorable, IUser {
    using SafeMath for uint256;

    event FileAdded(address indexed owner, string indexed cid); // for User Client
    event FileAddFailed(address indexed owner, string indexed cid); // for User Client
    event FileDeleted(address indexed owner, string indexed cid); // for User Client

    constructor(IResolver _resolver) public Importable(_resolver) {
        setContractName(CONTRACT_USER);
        imports = [
            CONTRACT_SETTING,
            CONTRACT_FILE,
            CONTRACT_NODE,
            CONTRACT_TASK
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

    function register(address addr, string calldata ext) external {
        require(!Storage().exist(addr), contractName.concat(": user exist"));
        require(bytes(ext).length <= Setting().getMaxUserExtLength(), contractName.concat(": user ext too long"));
        Storage().newUser(addr, Setting().getInitSpace(), ext);
    }

    function deRegister(address addr) public {
        require(Storage().exist(addr), contractName.concat(": user not exist"));
        require(0 == Storage().getFileNumber(addr), contractName.concat(": files not empty"));
        Storage().deleteUser(addr);
    }

    function exist(address addr) public returns (bool) {
        return Storage().exist(addr);
    }

    function getExt(address addr) external view returns (string memory) {
        return Storage().getExt(addr);
    }

    function setExt(address addr, string calldata ext) external {
        require(Storage().exist(addr), contractName.concat(": user not exist"));
        require(bytes(ext).length <= Setting().getMaxUserExtLength(), contractName.concat(": user ext too long"));
        Storage().setExt(addr, ext);
    }

    function addFile(address addr, string calldata cid, uint256 size, uint256 duration, string calldata ext) external {
        require(size > 0, contractName.concat(": size must > 0"));
        require(bytes(ext).length <= Setting().getMaxUserExtLength(), contractName.concat(": file ext too long"));
        require(bytes(cid).length <= Setting().getMaxCidLength(), contractName.concat(": cid too long"));
        require(!Storage().fileExist(addr, cid), contractName.concat(": file exist"));
        require(Storage().getStorageFree(addr) >= size, contractName.concat(": space not enough"));

        Storage().addFile(addr, cid, duration, ext, now);
        File().addFile(cid, size, addr);
    }

    function deleteFile(address addr, string memory cid) public {
        require(bytes(cid).length <= Setting().getMaxCidLength(), contractName.concat(": cid too long"));
        require(Storage().fileExist(addr, cid), contractName.concat(": file not exist"));

        Storage().deleteFile(addr, cid);
        File().deleteFile(cid, addr);
    }

    function getFileExt(address addr, string calldata cid) external view returns (string memory) {
        return Storage().getFileExt(addr, cid);
    }

    function setFileExt(address addr, string calldata cid, string calldata ext) external {
        require(Storage().exist(addr), contractName.concat(": user not exist"));
        require(Storage().fileExist(addr, cid), contractName.concat(": user have no the file"));
        require(bytes(ext).length <= Setting().getMaxFileExtLength(), contractName.concat(": file ext too long"));
        Storage().setFileExt(addr, cid, ext);
    }

    function getFileDuration(address addr, string calldata cid) external view returns (uint256) {
        return Storage().getFileDuration(addr, cid);
    }

    function setFileDuration(address addr, string calldata cid, uint256 duration) external {
        require(Storage().exist(addr), contractName.concat(": user not exist"));
        require(Storage().fileExist(addr, cid), contractName.concat(": user have no the file"));
        Storage().setFileDuration(addr, cid, duration);
    }

    function changeSpace(address addr, uint256 size) public {
        require(Storage().exist(addr), contractName.concat(": user not exist"));
        require(size >= Storage().getStorageUsed(addr), contractName.concat(": can not little than storage used"));
        Storage().setStorageTotal(addr, size);
    }

    function getStorageInfo(address addr) external view returns (IUserStorage.StorageInfo memory) {
        return Storage().getStorageInfo(addr);
    }

    function getCids(address addr, uint256 pageSize, uint256 pageNumber) external view returns(string[] memory, Paging.Page memory) {
        return Storage().getCids(addr, pageSize, pageNumber);
    }

    /////////////////////// callback functions ///////////////////////
    function callbackFinishAddFile(address owner, address node, string calldata cid) external {
        if(!File().ownerExist(cid, owner)) {
            uint256 size = File().getSize(cid);
            useStorage(owner, size);
            emit FileAdded(owner, cid);
        }
    }

    function callbackFailAddFile(address owner, string calldata cid) external {
        if(!File().ownerExist(cid, owner)) {
            uint256 invalidAddFileCount = Storage().getInvalidAddFileCount(owner);
            Storage().setInvalidAddFileCount(owner, invalidAddFileCount.add(1));
            emit FileAddFailed(owner, cid);
        }
    }

    function callbackFinishDeleteFile(address owner, address node, string calldata cid) external {
        uint256 size = File().getSize(cid);
        freeStorage(owner, size);
        emit FileDeleted(owner, cid);
    }

    /////////////////////// private functions ///////////////////////
    function useStorage(address node, uint256 size) private {
        IUserStorage.StorageInfo memory storageInfo = Storage().getStorageInfo(node);
        require(size > 0 && storageInfo.used.add(size) <= storageInfo.total, contractName.concat(": space not enough"));
        Storage().setStorageUsed(node, storageInfo.used.add(size));
    }

    function freeStorage(address node, uint256 size) private {
        IUserStorage.StorageInfo memory storageInfo = Storage().getStorageInfo(node);
        require(size > 0 && size <= storageInfo.used, contractName.concat("free size can not big than used size"));
        Storage().setStorageUsed(node, storageInfo.used.sub(size));
    }
}
