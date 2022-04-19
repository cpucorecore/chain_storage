pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import "./base/Importable.sol";
import "./base/ExternalStorable.sol";
import "./interfaces/IFile.sol";
import "./interfaces/storages/IFileStorage.sol";
import "./interfaces/INode.sol";

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

    function Node() private view returns (INode) {
        return INode(requireAddress(CONTRACT_NODE));
    }

    function addFile(string calldata cid, uint size, address owner, uint256 duration) external {
        if(Storage().exist(cid)) {
            if(!Storage().ownerExist(cid, owner)) {
                Storage().addOwner(cid, owner);
            }
        } else {
            Storage().newFile(cid, size);
            Node().addFile(cid, size, duration);
        }
    }

    function deleteFile(string calldata cid, address owner) external {
//        if(Storage().ownerExist(cid, owner)) {
//            Storage().delOwner(cid, owner);
//            address[] memory owners = Storage().owners(cid);
//            if(0 == owners.length) {
//                address[] storage nodes = Storage().nodes(cid);
//                for(uint i=0; i<nodes.length; i++) {
//                    // TODO Task().issueDeleteTask(cid, nodes[i], "");
//                }
//                // TODO issueDeleteTask all success then to deleteFile? or wait all node response: fileDeleted then to deleteFile?
//                Storage().deleteFile(cid);
//            }
//        }
    }

    function exist(string calldata cid) external view returns (bool) {
        return Storage().exist(cid);
    }

    function size(string calldata cid) external view returns (uint256) {
        return Storage().size(cid);
    }

    function fileAdded(string memory cid, address node) public {
//        Storage().addNode(cid, node);
    }

    function fileDeleted(string memory cid, address node) public {
//        Storage().delNode(cid, node);
    }

    function owners(string calldata cid, uint256 pageSize, uint256 pageNumber) external view returns(address[] memory, Paging.Page memory) {
//        return Storage().owners(cid, pageSize, pageNumber);
    }
}
