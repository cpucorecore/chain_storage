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

    constructor(IResolver _resolver) public Importable(_resolver) {
        setContractName(CONTRACT_USER);
        imports = [
            CONTRACT_SETTING,
            CONTRACT_FILE
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

    function register(address addr, string calldata ext) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        require(!Storage().exist(addr), "U:ue");
        Storage().newUser(addr, Setting().getInitSpace(), ext);
    }

    function deRegister(address addr) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        require(Storage().exist(addr), "U:une");
        require(0 == Storage().getFileNumber(addr), "U:fne"); // "files not empty"
        Storage().deleteUser(addr);
    }

    function setExt(address addr, string calldata ext) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        require(Storage().exist(addr), "U:une");
        Storage().setExt(addr, ext);
    }

    function changeSpace(address addr, uint256 size) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        require(Storage().exist(addr), "U:une");
        require(size >= Storage().getStorageUsed(addr), "U:sts"); // storage space too small
        Storage().setStorageTotal(addr, size);
    }

    function setFileExt(address addr, string calldata cid, string calldata ext) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        require(Storage().exist(addr), "U:une");
        require(Storage().fileExist(addr, cid), "U:nf"); // user have no this file
        Storage().setFileExt(addr, cid, ext);
    }

    function setFileDuration(address addr, string calldata cid, uint256 duration) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        require(Storage().exist(addr), "U:une");
        require(Storage().fileExist(addr, cid), "U:nf"); // user have no this file
        Storage().setFileDuration(addr, cid, duration);
    }

    function addFile(address addr, string calldata cid, uint256 size, uint256 duration, string calldata ext) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        require(size > 0, "U:zs"); // zero size
        require(!Storage().fileExist(addr, cid), "U:fe"); // file exist
        require(Storage().availableSpace(addr) >= size, "U:sne"); // storage space not enough
        emit UserAction(addr, Add, cid);
        File().addFile(cid, size, addr);
        Storage().addFile(addr, cid, duration, ext, now); // TODO check do in callback?
        Storage().useStorage(addr, size); // TODO do in callback
    }

    function deleteFile(address addr, string calldata cid) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        require(Storage().fileExist(addr, cid), "U:fne"); // file not exist
        emit UserAction(addr, Add, cid);
        File().deleteFile(cid, addr);
        Storage().deleteFile(addr, cid); // TODO check do in callback?
        Storage().freeStorage(addr, File().getSize(cid)); // TODO do in callback
    }
}
