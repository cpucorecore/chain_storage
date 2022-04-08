pragma solidity ^0.5.17;

import "./base/Importable.sol";
import "./base/ExternalStorable.sol";
import "./interfaces/IFile.sol";
import "./interfaces/storages/IFileStorage.sol";

contract File is Importable, ExternalStorable, IFile {
    constructor(IResolver _resolver) public Importable(_resolver) {
        setContractName(CONTRACT_FILE);
        imports = [
            CONTRACT_USER,
            CONTRACT_NODE,
            CONTRACT_TASK
        ];
    }

    function Storage() private view returns(IFileStorage) {
        return IFileStorage(getStorage());
    }

    function addFile(string calldata cid, uint size, address owner) external {
        if(Storage().exist(cid)) {
            if(Storage().ownerExist(cid, owner)) {
                return;
            }
            Storage().addOwner(cid, owner);
        }

        Storage().newFile(cid, size, owner, now);
    }

    function delFile(string calldata cid, address owner) external returns(bool) {
        if(Storage().ownerExist(cid, owner)) {
            Storage().delOwner(cid, owner);
            return true;
        }

        return false;
    }

    function exist(string calldata cid) public {
        return Storage().exist(cid);
    }

    function size(string calldata cid) public returns(uint) {
        return Storage().size(cid);

    }

    function addOwner(string calldata cid, address owner) public {
        if(Storage().exist(cid)) {
            Storage().addOwner(owner);
        }
    }

    function delOwner(string calldata cid, address owner) public returns(bool) {

    }

    function isOwnerOf(string calldata cid, address owner) public returns(bool) {

    }

    function owners(string calldata cid) returns(string[] memory) {

    }

    function addNode(string calldata cid, string memory pid) public {

    }

    function delNode(string calldata cid, string memory pid) public {

    }

    function nodeExist(string calldata cid, string memory pid) public returns(bool) {

    }
}
