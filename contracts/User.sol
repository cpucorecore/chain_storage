pragma solidity ^0.5.2;
pragma experimental ABIEncoderV2;

import "./base/Importable.sol";
import "./base/ExternalStorable.sol";
import "./interfaces/IUser.sol";
import "./interfaces/storages/IUserStorage.sol";
import "./interfaces/ISetting.sol";

contract User is Importable, ExternalStorable, IUser {
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
}
