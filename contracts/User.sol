pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import "./base/Importable.sol";
import "./base/ExternalStorable.sol";
import "./interfaces/storages/IUserStorage.sol";
import "./interfaces/IUser.sol";

contract User is Importable, ExternalStorable, IUser {
    constructor(IResolver _resolver) public Importable(_resolver) {
        setContractName(CONTRACT_FILE);
        imports = [
        CONTRACT_FILE,
        CONTRACT_NODE,
        CONTRACT_TASK
        ];
    }

    function Storage() private view returns(IUserStorage) {
        return IUserStorage(getStorage());
    }

    function register(uint256 space) public {
        require(false == Storage().exist(msg.sender), contractName.concat(": user exist"));
        require(space > 0, contractName.concat(": space must > 0"));
        Storage().newUser(msg.sender, space);
    }

    function deRegister() public {
        require(Storage().exist(msg.sender), contractName.concat(": user not exist"));
        //TODO delete all files, issue deleteFile task to TASK
        Storage().deleteUser(msg.sender);
    }

    function exist(address addr) public returns(bool) {
        return Storage().exist(addr);
    }

    function addFile(string memory cid, uint256 size, uint256 duration, string memory ext) public {
        require(false == Storage().fileExist(msg.sender, cid), contractName.concat(": file exist"));
        // TODO File().addFile
        Storage().addFile(msg.sender, cid, size, duration, ext);
    }

    function deleteFile(string memory cid) public {
        require(Storage().fileExist(msg.sender, cid), contractName.concat(": file not exist"));
        // TODO File().addFile
        Storage().deleteFile(msg.sender, cid);
    }

    function changeSpace(address addr, uint256 size) public {
        address admin; // admin in config
        require(admin == msg.sender, ": no auth");
        Storage().storageSpace(addr, size);
    }

    function cids() public returns(string[] memory) {
        return Storage().cids(msg.sender);
    }

    function storageInfo() public returns(uint256, uint256) {
        return Storage().storageInfo(msg.sender);
    }
}
