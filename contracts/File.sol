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
            if(IFileStorage.Status.Deleting == Storage().getStatus(cid)) {
                Storage().setStatus(cid, IFileStorage.Status.Adding);
                Node().addFile(owner, cid, size);
            }
            if(!Storage().ownerExist(cid, owner)) {
                Storage().addOwner(cid, owner);
            }
        } else {
            Storage().newFile(cid, size);
            Storage().addOwner(cid, owner);
            Node().addFile(owner, cid, size);
        }
    }

    function deleteFile(string calldata cid, address owner) external {
        require(IFileStorage.Status.Deleting != Storage().getStatus(cid), contractName.concat(": should not be happen: file status is Deleting"));
        require(Storage().ownerExist(cid, owner), contractName.concat(": should not be happen: owner not exist"));

        Storage().delOwner(cid, owner);
        if(Storage().ownerEmpty(cid)) {
            Storage().setStatus(cid, IFileStorage.Status.Deleting);
            address[] memory nodes = Storage().getNodes(cid);
            for(uint i=0; i<nodes.length; i++) {
                Task().issueTask(ITaskStorage.Action.Delete, owner, cid, nodes[i], Storage().getSize(cid));
            }
        }
    }

    function exist(string calldata cid) external view returns (bool) {
        return Storage().exist(cid);
    }

    function getStatus(string calldata cid) external view returns (IFileStorage.Status) {
        return Storage().getStatus(cid);
    }

    function getSize(string calldata cid) external view returns (uint256) {
        return Storage().size(cid);
    }

    function fileAdded(address node, address owner, string calldata cid) external {
        require(!Storage().nodeExist(cid, node), contractName.concat(": node exist"));
        Storage().addNode(cid, node);

        IFileStorage.Status status = Storage().getStatus(cid);
        if(IFileStorage.Status.Adding == status) {
            Storage().setStatus(cid, IFileStorage.Status.Added);
            User().finishAddFile(owner, node, cid);
        } else if(IFileStorage.Status.Deleting == status) {
            Task().issueTask(ITaskStorage.Action.Delete, owner, cid, node, Storage().getSize(cid));
        }
    }

    function fileDeleted(address node, address owner, string calldata cid) external {
        require(Storage().nodeExist(cid, node), contractName.concat(": node not exist"));
        Storage().delNode(cid, node);

        if(Storage().nodeEmpty(cid)) {
            IFileStorage.Status status = Storage().getStatus(cid);
            if(IFileStorage.Status.Deleting == status) {
                Storage().deleteFile(cid);
                User().finishDeleteFile(owner, node, cid);
            }
        }
    }

    function ownerExist(string calldata cid, address owner) external view returns (bool) {
        return Storage().ownerExist(cid, owner);
    }

    function getOwners(string calldata cid, uint256 pageSize, uint256 pageNumber) external view returns (address[] memory, Paging.Page memory) {
        return Storage().getOwners(cid, pageSize, pageNumber);
    }
}
