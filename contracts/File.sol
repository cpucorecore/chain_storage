pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import "./base/Importable.sol";
import "./base/ExternalStorable.sol";
import "./interfaces/IFile.sol";
import "./interfaces/storages/IFileStorage.sol";
import "./interfaces/INode.sol";
import "./interfaces/ITask.sol";
import "./interfaces/IUser.sol";

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

    function User() private view returns (IUser) {
        return IUser(requireAddress(CONTRACT_USER));
    }

    function Node() private view returns (INode) {
        return INode(requireAddress(CONTRACT_NODE));
    }

    function Task() private view returns (ITask) {
        return ITask(requireAddress(CONTRACT_TASK));
    }

    function addFile(string calldata cid, uint256 size, address owner) external {
        require(IFileStorage.Status.Deleting != Storage().getStatus(cid), contractName.concat(": should not be happen: file status is Deleting"));

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

        Storage().deleteOwner(cid, owner);
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
        return Storage().getSize(cid);
    }

    function fileAdded(address node, address owner, string calldata cid) external {
        IFileStorage.Status status = Storage().getStatus(cid);
        if(IFileStorage.Status.Deleting == status) {
            if(nodeExist(cid, node)) {
                Task().issueTask(ITaskStorage.Action.Delete, owner, cid, node, Storage().getSize(cid));
            }
        } else {
            if(IFileStorage.Status.Adding == status) {
                Storage().setStatus(cid, IFileStorage.Status.Added);
            }

            if(!Storage().nodeExist(cid, node)) {
                Storage().addNode(cid, node);
                if(Storage().ownerExist(cid, owner)) {
                    User().callbackFinishAddFile(owner, node, cid);
                }
            }
        }
    }

    function fileDeleted(address node, address owner, string calldata cid) external {
        if(!Storage().nodeExist(cid, node)) {
            return;
        }
        Storage().deleteNode(cid, node);

        if(Storage().nodeEmpty(cid)) {
            IFileStorage.Status status = Storage().getStatus(cid);
            if(IFileStorage.Status.Deleting == status) {
                Storage().deleteFile(cid);
            }
            User().callbackFinishDeleteFile(owner, node, cid);
        }
    }

    function ownerExist(string memory cid, address owner) public view returns (bool) {
        return Storage().ownerExist(cid, owner);
    }

    function getOwners(string calldata cid) external view returns (address[] memory) {
        return Storage().getOwners(cid);
    }

    function getOwners(string calldata cid, uint256 pageSize, uint256 pageNumber) external view returns (address[] memory, Paging.Page memory) {
        return Storage().getOwners(cid, pageSize, pageNumber);
    }

    function nodeExist(string memory cid, address node) public view returns (bool) {
        return Storage().nodeExist(cid, node);
    }

    function getNodes(string calldata cid) external view returns (address[] memory) {
        return Storage().getNodes(cid);
    }

    function getNodes(string calldata cid, uint256 pageSize, uint256 pageNumber) external view returns (address[] memory, Paging.Page memory) {
        return Storage().getNodes(cid, pageSize, pageNumber);
    }
}
