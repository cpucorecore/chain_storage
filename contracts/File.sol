pragma solidity ^0.5.2;
pragma experimental ABIEncoderV2;

import "./base/Importable.sol";
import "./base/ExternalStorable.sol";
import "./interfaces/IFile.sol";
import "./interfaces/storages/IFileStorage.sol";
import "./interfaces/INode.sol";
import "./interfaces/ITask.sol";
import "./interfaces/IUser.sol";
import "./interfaces/IUserCallback.sol";

contract File is Importable, ExternalStorable, IFile {
    constructor(IResolver _resolver) public Importable(_resolver) {
        setContractName(CONTRACT_FILE);
        imports = [
            CONTRACT_USER,
            CONTRACT_USER_CALLBACK,
            CONTRACT_NODE,
            CONTRACT_TASK
        ];
    }

    function Storage() private view returns (IFileStorage) {
        return IFileStorage(getStorage());
    }

    function User() private view returns (IUser) {
        return IUser(requireAddress(CONTRACT_USER));
    }

    function UserCallback() private view returns (IUserCallback) {
        return IUserCallback(requireAddress(CONTRACT_USER_CALLBACK));
    }

    function Node() private view returns (INode) {
        return INode(requireAddress(CONTRACT_NODE));
    }

    function Task() private view returns (ITask) {
        return ITask(requireAddress(CONTRACT_TASK));
    }

    function exist(string calldata cid) external view returns (bool) {
        return Storage().exist(cid);
    }

    function addFile(string calldata cid, uint256 size, address owner) external {
        mustAddress(CONTRACT_USER);

        if(!Storage().exist(cid)) {
            Storage().newFile(cid, size);
            Node().addFile(owner, cid, size);
        }

        if(!Storage().ownerExist(cid, owner)) {
            Storage().addOwner(cid, owner);
        }
    }

    function addFileCallback(address node, address owner, string calldata cid) external {
        mustAddress(CONTRACT_NODE);

        UserCallback().callbackFinishAddFile(owner, node, cid);
        if(Storage().exist(cid)) {
            if(!nodeExist(cid, node)) {
                Storage().addNode(cid, node);
            }
        } else {
            Task().issueTask(Delete, owner, cid, node, Storage().getSize(cid));
        }
    }

    function deleteFile(string calldata cid, address owner) external {
        mustAddress(CONTRACT_USER);

        require(Storage().exist(cid), "F:ne");

        if(Storage().ownerExist(cid, owner)) {
            Storage().deleteOwner(cid, owner);
        }

        if(Storage().ownerEmpty(cid)) {
            if(Storage().nodeEmpty(cid)) {
                Storage().deleteFile(cid);
            } else {
                address[] memory nodes = Storage().getNodes(cid);
                for(uint i=0; i<nodes.length; i++) {
                    Task().issueTask(Delete, owner, cid, nodes[i], Storage().getSize(cid));
                }
            }
        }
    }

    function deleteFileCallback(address node, address owner, string calldata cid) external {
        mustAddress(CONTRACT_NODE);

        UserCallback().callbackFinishDeleteFile(owner, node, cid);
        if(Storage().nodeExist(cid, node)) {
            Storage().deleteNode(cid, node);
        }

        if(Storage().nodeEmpty(cid)) {
            if(Storage().ownerEmpty(cid)) {
                Storage().deleteFile(cid);
            }
        }
    }

    function getSize(string calldata cid) external view returns (uint256) {
        return Storage().getSize(cid);
    }

    function ownerExist(string memory cid, address owner) public view returns (bool) {
        return Storage().ownerExist(cid, owner);
    }

    function getOwners(string calldata cid) external view returns (address[] memory) {
        return Storage().getOwners(cid);
    }

    function getOwners(string calldata cid, uint256 pageSize, uint256 pageNumber) external view returns (address[] memory, bool) {
        return Storage().getOwners(cid, pageSize, pageNumber);
    }

    function nodeExist(string memory cid, address node) public view returns (bool) {
        return Storage().nodeExist(cid, node);
    }

    function getNodes(string calldata cid) external view returns (address[] memory) {
        return Storage().getNodes(cid);
    }

    function getNodes(string calldata cid, uint256 pageSize, uint256 pageNumber) external view returns (address[] memory, bool) {
        return Storage().getNodes(cid, pageSize, pageNumber);
    }

    function getTotalSize() external view returns (uint256) {
        return Storage().getTotalSize();
    }

    function getTotalFileNumber() external view returns (uint256) {
        return Storage().getTotalFileNumber();
    }
}
