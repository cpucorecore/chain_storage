pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

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

        // TODO Node().addFile(cid, size)
    }

    function deleteFile(string calldata cid, address owner) external returns(bool) {
        if(Storage().ownerExist(cid, owner)) {
            Storage().delOwner(cid, owner);

            if(0 == Storage().owners(cid).length) {
                string[] memory nodes = Storage().nodes(cid);
                for(uint i=0; i<nodes.length; i++) {
                    // TODO Task().issueDeleteTask(cid, nodes[i], "");
                }
            }
            return true;
        }

        return false;
    }

    function fileAdded(string memory cid, string memory pid) public {
        Storage().addNode(cid, pid);
    }

    function fileDeleted(string memory cid, string memory pid) public {
        Storage().delNode(cid, pid);
    }
}
