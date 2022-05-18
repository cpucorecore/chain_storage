pragma solidity ^0.5.2;

import "./base/Importable.sol";
import "./base/ExternalStorable.sol";
import "./interfaces/IUser.sol";
import "./interfaces/storages/IUserStorage.sol";
import "./interfaces/ISetting.sol";
import "./interfaces/IFile.sol";

contract User is Importable, ExternalStorable, IUser {
    event UserAction(address indexed addr, uint256 action, string cid);
    event FileAdded(address indexed owner, string cid);
    event FileAddFailed(address indexed owner, string cid);
    event FileDeleted(address indexed owner, string cid);

    constructor(IResolver _resolver) public Importable(_resolver) {
        setContractName(CONTRACT_USER);
        imports = [
            CONTRACT_SETTING,
            CONTRACT_FILE,
            CONTRACT_CHAIN_STORAGE
        ];
    }

    function _Storage() private view returns (IUserStorage) {
        return IUserStorage(getStorage());
    }

    function _Setting() private view returns (ISetting) {
        return ISetting(requireAddress(CONTRACT_SETTING));
    }

    function _File() private view returns (IFile) {
        return IFile(requireAddress(CONTRACT_FILE));
    }

    function register(address addr, string calldata ext) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        require(!_Storage().exist(addr), "U:user exist");
        _Storage().newUser(addr, _Setting().getInitSpace(), ext);
    }

    function setExt(address addr, string calldata ext) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        require(_Storage().exist(addr), "U:user not exist");
        _Storage().setExt(addr, ext);
    }

    function setStorageTotal(address addr, uint256 size) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        require(_Storage().exist(addr), "U:user not exist");
        require(size >= _Storage().getStorageUsed(addr), "U:storage space too small");
        _Storage().setStorageTotal(addr, size);
    }

    function deRegister(address addr) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        require(_Storage().exist(addr), "U:user not exist");
        require(0 == _Storage().getFileNumber(addr), "U:files not empty");
        _Storage().deleteUser(addr);
    }

    function addFile(address addr, string calldata cid, uint256 duration, string calldata ext) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        require(_Storage().exist(addr), "U:user not exist");
        require(!_Storage().fileExist(addr, cid), "U:file exist");
        emit UserAction(addr, Add, cid);
        bool finish = _File().addFile(cid, addr);
        if(finish) {
            _Storage().useStorage(owner, _File().getSize(cid));
        }
        _Storage().addFile(addr, cid, duration, ext, now);
    }

    function setFileExt(address addr, string calldata cid, string calldata ext) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        require(_Storage().exist(addr), "U:user not exist");
        require(_Storage().fileExist(addr, cid), "U:no file");
        _Storage().setFileExt(addr, cid, ext);
    }

    function setFileDuration(address addr, string calldata cid, uint256 duration) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        require(_Storage().exist(addr), "U:user not exist");
        require(_Storage().fileExist(addr, cid), "U:file not exist");
        _Storage().setFileDuration(addr, cid, duration);
    }

    function deleteFile(address addr, string calldata cid) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        require(_Storage().exist(addr), "U:user not exist");
        require(_Storage().fileExist(addr, cid), "U:file not exist");
        emit UserAction(addr, Delete, cid);
        uint256 size = _File().getSize(cid);
        bool finish = _File().deleteFile(cid, addr);
        if(finish) {
            _Storage().freeStorage(owner, size);
        }
    }

    function onAddFileFinish(address owner, string calldata cid, uint256 size) external {
        mustAddress(CONTRACT_FILE);
        _Storage().useStorage(owner, size);
    }

    function onAddFileFail(address owner, string calldata cid) external {
        mustAddress(CONTRACT_FILE);
        _Storage().upInvalidAddFileCount(owner);
        emit FileAddFailed(owner, cid);
    }

    function onDeleteFileFinish(address owner, string calldata cid, uint256 size) external {
        mustAddress(CONTRACT_FILE);
        emit FileDeleted(owner, cid);
        _Storage().deleteFile(owner, cid);
        _Storage().freeStorage(owner, size);
    }
}
