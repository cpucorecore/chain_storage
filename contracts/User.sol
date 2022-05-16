pragma solidity ^0.5.2;
pragma experimental ABIEncoderV2;

import "./base/Importable.sol";
import "./base/ExternalStorable.sol";
import "./interfaces/IUser.sol";
import "./interfaces/storages/IUserStorage.sol";
import "./interfaces/ISetting.sol";
import "./interfaces/IFile.sol";
import "./lib/SafeMath.sol";

contract User is Importable, ExternalStorable, IUser {
    using SafeMath for uint256;

    event UserAction(address indexed addr, uint256 action, string cid);
    event FileAdded(address indexed owner, string cid);
    event FileAddFailed(address indexed owner, string cid);
    event FileDeleted(address indexed owner, string cid);

    constructor(IResolver _resolver) public Importable(_resolver) {
        setContractName(CONTRACT_USER);
        imports = [
            CONTRACT_SETTING,
            CONTRACT_FILE
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

    function deRegister(address addr) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        require(_Storage().exist(addr), "U:user not exist");
        require(0 == _Storage().getFileNumber(addr), "U:files not empty");
        _Storage().deleteUser(addr);
    }

    function setExt(address addr, string calldata ext) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        require(_Storage().exist(addr), "U:user not exist");
        _Storage().setExt(addr, ext);
    }

    function changeSpace(address addr, uint256 size) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        require(_Storage().exist(addr), "U:user not exist");
        require(size >= _Storage().getStorageUsed(addr), "U:storage space too small");
        _Storage().setStorageTotal(addr, size);
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

    function addFile(address addr, string calldata cid, uint256 duration, string calldata ext) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        require(!_Storage().fileExist(addr, cid), "U:file exist");
        emit UserAction(addr, Add, cid);
        _File().addFile(cid, addr);
        _Storage().addFile(addr, cid, duration, ext, now);
    }

    function deleteFile(address addr, string calldata cid) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        require(_Storage().fileExist(addr, cid), "U:file not exist");
        emit UserAction(addr, Add, cid);
        _File().deleteFile(cid, addr);
    }

    function onAddFileFinish(address owner, string calldata cid, uint256 size) external {
        mustAddress(CONTRACT_FILE);
        _Storage().useStorage(owner, size);
    }

    function onAddFileFail(address owner, string calldata cid) external {
        mustAddress(CONTRACT_NODE);
        if(!_File().ownerExist(cid, owner)) {
            uint256 invalidAddFileCount = _Storage().getInvalidAddFileCount(owner);
            _Storage().setInvalidAddFileCount(owner, invalidAddFileCount.add(1));
            emit FileAddFailed(owner, cid);
        }
    }

    function onDeleteFileFinish(address owner, string calldata cid, uint256 size) external {
        mustAddress(CONTRACT_FILE);
        emit FileDeleted(owner, cid);
        _Storage().deleteFile(owner, cid);
        _Storage().freeStorage(owner, size);
    }
}
