pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import "./base/Importable.sol";
import "./base/ExternalStorable.sol";
import "./interfaces/storages/IUserStorage.sol";
import "./interfaces/IUser.sol";
import "./interfaces/ISetting.sol";
import "./interfaces/IFile.sol";

contract User is Importable, ExternalStorable, IUser {
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
        //TODO delete all files, issue deleteFile task to TASK
        Storage().deleteUser(addr);
    }

    function exist(address addr) public returns(bool) {
        return Storage().exist(addr);
    }

    function addFile(address addr, string calldata cid, uint256 size, uint256 duration, string calldata ext) external {
        require(!Storage().fileExist(addr, cid), contractName.concat(": file exist"));
        require(Storage().spaceEnough(addr, size), contractName.concat(": space not enough"));

        File().addFile(cid, size, addr, duration);

        Storage().addFile(addr, cid, duration, ext);
        Storage().useSpace(addr, size);
    }

    function deleteFile(address addr, string memory cid) public {
        require(Storage().fileExist(addr, cid), contractName.concat(": file not exist"));

        uint256 size = File().size(cid);
        Storage().freeSpace(addr, size);
        Storage().deleteFile(addr, cid);
        File().deleteFile(cid, addr);
    }

    function changeSpace(address addr, uint256 size) public {
        require(Setting().getAdmin() == msg.sender, ": no auth");
        Storage().setSpace(addr, size);
    }

    function cids(address addr, uint256 pageSize, uint256 pageNumber) external view returns(string[] memory, Paging.Page memory) {
        return Storage().cids(addr, pageSize, pageNumber);
    }

    function storageInfo(address addr) public returns(uint256, uint256) {
        return Storage().storageInfo(addr);
    }
}
