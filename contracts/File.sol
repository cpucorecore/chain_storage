pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import "./base/Importable.sol";
import "./base/ExternalStorable.sol";
import "./interfaces/IFile.sol";
import "./interfaces/storages/IFileStorage.sol";
import "./interfaces/INode.sol";
import "./interfaces/ITask.sol";

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

    function Task() private view returns (ITask) {
        return ITask(requireAddress(CONTRACT_TASK));
    }

    function addFile(string calldata cid, uint size, address owner) external {
        if(Storage().exist(cid)) {
            if(!Storage().ownerExist(cid, owner)) {
                Storage().addOwner(cid, owner);
            }
        } else {
            Storage().newFile(cid, size);
            Storage().addOwner(cid, owner); // TODO wait node return FileAdded?
            Node().addFile(owner, cid, size);
        }
    }

    function deleteFile(string calldata cid, address owner) external {
        if(Storage().ownerExist(cid, owner)) {
            uint256 size = Storage().size(cid);
            Storage().delOwner(cid, owner);
            address[] memory owners = Storage().owners(cid);
            if(0 == owners.length) {
                address[] memory nodes = Storage().nodes(cid);
                for(uint i=0; i<nodes.length; i++) {
                    Task().issueTask(ITaskStorage.Action.Delete, owner, cid, nodes[i], size);
                }
            }
        }
    }

    function exist(string calldata cid) external view returns (bool) {
        return Storage().exist(cid);
    }

    function getSize(string calldata cid) external view returns (uint256) {
        return Storage().size(cid);
    }

    function fileAdded(string calldata cid, address node) external {
        require(!Storage().nodeExist(cid, node), contractName.concat(": node exist"));
        Storage().addNode(cid, node);
    }

    function fileDeleted(string calldata cid, address node) external {
        require(Storage().nodeExist(cid, node), contractName.concat(": node not exist"));
        Storage().delNode(cid, node);
        if(Storage().nodeEmpty(cid)) {
            Storage().deleteFile(cid);
        }
    }

    function ownerExist(string calldata cid, address owner) external view returns (bool) {
        return Storage().ownerExist(cid, owner);
    }

    function owners(string calldata cid, uint256 pageSize, uint256 pageNumber) external view returns (address[] memory, Paging.Page memory) {
        return Storage().owners(cid, pageSize, pageNumber);
    }
}
