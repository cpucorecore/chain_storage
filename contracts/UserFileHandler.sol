pragma solidity ^0.5.2;

import "./base/Importable.sol";
import "./base/ExternalStorable.sol";
import "./interfaces/IUserFileHandler.sol";
import "./lib/SafeMath.sol";
import "./interfaces/storages/IUserStorage.sol";
import "./interfaces/ISetting.sol";
import "./interfaces/IFile.sol";
import "./interfaces/IHistory.sol";

contract UserFileHandler is Importable, ExternalStorable, IUserFileHandler {
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

    function Storage() private view returns (IUserStorage) {
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
        emit FileDeleted(owner, cid);
    }

    function useStorage(address addr, uint256 size) private {
        uint256 used = Storage().getStorageUsed(addr);
        uint256 total = Storage().getStorageTotal(addr);
        require(size > 0 && used.add(size) <= total, contractName.concat(": space not enough"));
        Storage().setStorageUsed(addr, used.add(size));
    }

    function freeStorage(address addr, uint256 size) private {
        uint256 used = Storage().getStorageUsed(addr);
        require(size > 0 && size <= used, contractName.concat(": free size can not big than used size"));
        Storage().setStorageUsed(addr, used.sub(size));
    }
}
