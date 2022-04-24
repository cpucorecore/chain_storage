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

    event FileAdded(address indexed owner, string indexed cid);
    event FileDeleted(address indexed owner, string indexed cid);

    constructor(IResolver _resolver) public Importable(_resolver) {
        setContractName(CONTRACT_FILE);
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
        Storage().newUser(addr, Setting().getInitSpace(), ext);
    }

    function deRegister(address addr) public {
        require(Storage().exist(addr), contractName.concat(": user not exist"));
        require(0 == Storage().getFileNumber(addr), contractName.concat(": files not empty"));
        Storage().deleteUser(addr);
    }

    function exist(address addr) public returns(bool) {
        return Storage().exist(addr);
    }

    function addFile(address addr, string calldata cid, uint256 size, uint256 duration, string calldata ext) external {
        require(!Storage().fileExist(addr, cid), contractName.concat(": file exist"));
        require(Storage().getStorageFree(addr) >= size, contractName.concat(": space not enough"));

        File().addFile(cid, size, addr);
        Storage().addFile(addr, cid, duration, ext, now);
    }

    function deleteFile(address addr, string memory cid) public {
        require(Storage().fileExist(addr, cid), contractName.concat(": file not exist"));

        Storage().deleteFile(addr, cid);
        File().deleteFile(cid, addr);
    }

    function finishAddFile(address owner, address node, string calldata cid) external {
        if(!File().ownerExist(cid, owner)) {
            uint256 size = File().getSize(cid);
            useStorage(owner, size);
        }
    }

    function finishDeleteFile(address owner, address node, string calldata cid) external {
        if(File().ownerExist(cid, owner)) {
            uint256 size = File().getSize(cid);
            freeStorage(owner, size);
        }
    }

    function getFileExt(address addr, string calldata cid) external view returns (string memory) {
        return Storage().getFileExt(addr, cid);
    }

    function setFileExt(address addr, string calldata cid, string calldata ext) external {
        Storage().setFileExt(addr, cid, ext);
    }

    function getFileDuration(address addr, string calldata cid) external view returns (uint256) {
        return Storage().getFileDuration(addr, cid);
    }

    function setFileDuration(address addr, string calldata cid, uint256 duration) external {
        Storage().setFileDuration(addr, cid, duration);
    }

    function changeSpace(address addr, uint256 size) public {
        require(Setting().getAdmin() == msg.sender, ": no auth");
        require(size >= Storage().getStorageUsed(addr), contractName.concat(": can not little than storage used bigger"));
        Storage().setStorageTotal(addr, size);
    }

    function getStorageInfo(address addr) external view returns (IUserStorage.StorageInfo memory) {
        return Storage().getStorageInfo(addr);
    }

    function getCids(address addr, uint256 pageSize, uint256 pageNumber) external view returns(string[] memory, Paging.Page memory) {
        return Storage().getCids(addr, pageSize, pageNumber);
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
