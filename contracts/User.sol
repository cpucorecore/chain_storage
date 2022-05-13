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
        require(!Storage().exist(addr), contractName.concat(": user exist"));
        require(bytes(ext).length <= Setting().getMaxUserExtLength(), contractName.concat(": user ext too long"));
        Storage().newUser(addr, Setting().getInitSpace(), ext);
    }

    function deRegister(address addr) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        require(Storage().exist(addr), contractName.concat(": user not exist"));
        require(0 == Storage().getFileNumber(addr), contractName.concat(": files not empty"));
        Storage().deleteUser(addr);
    }

    function setExt(address addr, string calldata ext) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        require(Storage().exist(addr), contractName.concat(": user not exist"));
        require(bytes(ext).length <= Setting().getMaxUserExtLength(), contractName.concat(": user ext too long"));
        Storage().setExt(addr, ext);
    }

    function changeSpace(address addr, uint256 size) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        require(Storage().exist(addr), contractName.concat(": user not exist"));
        require(size >= Storage().getStorageUsed(addr), contractName.concat(": can not little than storage used"));
        Storage().setStorageTotal(addr, size);
    }

    function setFileExt(address addr, string calldata cid, string calldata ext) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        require(Storage().exist(addr), contractName.concat(": user not exist"));
        require(Storage().fileExist(addr, cid), contractName.concat(": user have no the file"));
        require(bytes(ext).length <= Setting().getMaxFileExtLength(), contractName.concat(": file ext too long"));
        Storage().setFileExt(addr, cid, ext);
    }

    function setFileDuration(address addr, string calldata cid, uint256 duration) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        require(Storage().exist(addr), contractName.concat(": user not exist"));
        require(Storage().fileExist(addr, cid), contractName.concat(": user have no the file"));
        Storage().setFileDuration(addr, cid, duration);
    }

    function addFile(address addr, string calldata cid, uint256 size, uint256 duration, string calldata ext) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        require(size > 0, contractName.concat(": size must > 0"));
        require(bytes(ext).length <= Setting().getMaxUserExtLength(), contractName.concat(": file ext too long"));
        require(bytes(cid).length <= Setting().getMaxCidLength(), contractName.concat(": cid too long"));
        require(!Storage().fileExist(addr, cid), contractName.concat(": file exist"));
        require(Storage().getStorageFree(addr) >= size, contractName.concat(": space not enough"));

        emit UserAction(addr, Add, cid);
        File().addFile(cid, size, addr);
        Storage().addFile(addr, cid, duration, ext, now);
        _useStorage(addr, size);
    }

    function deleteFile(address addr, string calldata cid) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        require(bytes(cid).length <= Setting().getMaxCidLength(), contractName.concat(": cid too long"));
        require(Storage().fileExist(addr, cid), contractName.concat(": file not exist"));

        emit UserAction(addr, Add, cid);
        Storage().deleteFile(addr, cid);
        uint256 size = File().getSize(cid);
        _freeStorage(addr, size);
        File().deleteFile(cid, addr);
    }

    function _useStorage(address addr, uint256 size) private {
        uint256 used = Storage().getStorageUsed(addr);
        uint256 total = Storage().getStorageTotal(addr);
        require(size > 0 && used.add(size) <= total, contractName.concat(": space not enough"));
        Storage().setStorageUsed(addr, used.add(size));
    }

    function _freeStorage(address addr, uint256 size) private {
        uint256 used = Storage().getStorageUsed(addr);
        require(size > 0 && size <= used, contractName.concat(": free size can not big than used size"));
        Storage().setStorageUsed(addr, used.sub(size));
    }
}
