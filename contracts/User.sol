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
    event FileAdded(address indexed owner, string cid); // for User Client
    event FileAddFailed(address indexed owner, string cid); // for User Client
    event FileDeleted(address indexed owner, string cid); // for User Client

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
        require(!_Storage().exist(addr), "U:ue");
        _Storage().newUser(addr, _Setting().getInitSpace(), ext);
    }

    function deRegister(address addr) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        require(_Storage().exist(addr), "U:une");
        require(0 == _Storage().getFileNumber(addr), "U:fne"); // "files not empty"
        _Storage().deleteUser(addr);
    }

    function setExt(address addr, string calldata ext) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        require(_Storage().exist(addr), "U:une");
        _Storage().setExt(addr, ext);
    }

    function changeSpace(address addr, uint256 size) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        require(_Storage().exist(addr), "U:une");
        require(size >= _Storage().getStorageUsed(addr), "U:sts"); // storage space too small
        _Storage().setStorageTotal(addr, size);
    }

    function setFileExt(address addr, string calldata cid, string calldata ext) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        require(_Storage().exist(addr), "U:une");
        require(_Storage().fileExist(addr, cid), "U:nf"); // user have no this file
        _Storage().setFileExt(addr, cid, ext);
    }

    function setFileDuration(address addr, string calldata cid, uint256 duration) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        require(_Storage().exist(addr), "U:une");
        require(_Storage().fileExist(addr, cid), "U:nf"); // user have no this file
        _Storage().setFileDuration(addr, cid, duration);
    }

    function addFile(address addr, string calldata cid, uint256 duration, string calldata ext) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        require(!_Storage().fileExist(addr, cid), "U:fe"); // file exist
        emit UserAction(addr, Add, cid);
        _File().addFile(cid, addr);
        _Storage().addFile(addr, cid, duration, ext, now);
    }

    function deleteFile(address addr, string calldata cid) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        require(_Storage().fileExist(addr, cid), "U:fne"); // file not exist
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
