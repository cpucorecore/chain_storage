pragma solidity ^0.5.2;

import "./base/Importable.sol";
import "./base/ExternalStorable.sol";
import "./interfaces/INodeFileHandler.sol";
import "./lib/SafeMath.sol";
import "./interfaces/storages/INodeStorage.sol";
import "./interfaces/ISetting.sol";
import "./interfaces/ITask.sol";
import "./interfaces/storages/ITaskStorage.sol";
import "./interfaces/IFile.sol";
import "./interfaces/IUserFileHandler.sol";
import "./interfaces/storages/INodeStorageViewer.sol";

contract NodeFileHandler is Importable, ExternalStorable, INodeFileHandler {
    using SafeMath for uint256;

    event NodeStatusChanged(address indexed addr, uint256 from, uint256 to);

    constructor(IResolver _resolver) public Importable(_resolver) {
        setContractName(CONTRACT_NODE_FILE_HANDLER);
        imports = [
            CONTRACT_SETTING,
            CONTRACT_FILE,
            CONTRACT_USER_FILE_HANDLER,
            CONTRACT_TASK
        ];
    }

    function Storage() private view returns (INodeStorage) {
        return INodeStorage(getStorage());
    }

    function StorageViewer() private view returns (INodeStorageViewer) {
        return INodeStorageViewer(getStorage());
    }

    function Setting() private view returns (ISetting) {
        return ISetting(requireAddress(CONTRACT_SETTING));
    }

    function Task() private view returns (ITask) {
        return ITask(requireAddress(CONTRACT_TASK));
    }

    function TaskStorage() private view returns (ITaskStorage) {
        return ITaskStorage(requireAddress(CONTRACT_TASK_STORAGE));
    }

    function File() private view returns (IFile) {
        return IFile(requireAddress(CONTRACT_FILE));
    }

    function UserFileHandler() private view returns (IUserFileHandler) {
        return IUserFileHandler(requireAddress(CONTRACT_USER_FILE_HANDLER));
    }

    function addFile(address owner, string calldata cid, uint256 size) external {
        mustAddress(CONTRACT_FILE);

        uint256 replica = Setting().getReplica();
        require(0 != replica, "NodeFileHandler: replica is 0");

        address[] memory nodeAddrs = selectNodes(size, replica);
        require(nodeAddrs.length == replica, "NodeFileHandler: no available node");

        for(uint256 i=0; i<nodeAddrs.length; i++) {
            Task().issueTask(Add, owner, cid, nodeAddrs[i], size);
        }
    }

    function finishTask(address addr, uint256 tid) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        address owner;
        uint256 action;
        address node;
        uint256 size;
        string memory cid;

        (owner, action, node, size, cid) = TaskStorage().getTask(tid);

        require(addr == node, "NodeFileHandler: node have no this task");

        if(Add == action) {
            File().addFileCallback(node, owner, cid);
            Storage().useStorage(node, size);
            Storage().resetAddFileFailedCount(cid);
        } else if(Delete == action) {
            File().deleteFileCallback(node, owner, cid);
            Storage().freeStorage(node, size);
        }

        uint256 currentTid = StorageViewer().getMaxFinishedTid(addr);
        if(tid > currentTid) {
            Storage().setMaxFinishedTid(addr, tid);
        }

        Task().finishTask(tid);
    }

    function failTask(address addr, uint256 tid) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        address node = TaskStorage().getNode(tid);
        require(addr == node, "NodeFileHandler: node have no this task");

        address owner = TaskStorage().getOwner(tid);
        string memory cid = TaskStorage().getCid(tid);
        uint256 size = TaskStorage().getSize(tid);
        uint256 action = TaskStorage().getAction(tid);
        require(Add == action, "NodeFileHandler: only Add task can fail");

        uint256 maxAddFileFailedCount = Setting().getMaxAddFileFailedCount();
        uint256 addFileFailedCount = Storage().upAddFileFailedCount(cid);
        if(addFileFailedCount >= maxAddFileFailedCount) {
            UserFileHandler().callbackFailAddFile(owner, cid);
            return;
        }

        address[] memory nodes = selectNodes(size, 1);
        require(1 == nodes.length, "NodeFileHandler: no available node:1"); // TODO check: no require?
        Task().issueTask(Add, owner, cid, nodes[0], size);

        Task().failTask(tid);
    }

    function taskAcceptTimeout(address addr, uint256 tid) external {
        mustAddress(CONTRACT_MONITOR);
        // TODO: Node should verify the taskAcceptTimeout Report by Monitor
        address node = TaskStorage().getNode(tid);
        address owner = TaskStorage().getOwner(tid);
        string memory cid = TaskStorage().getCid(tid);
        uint256 size = TaskStorage().getSize(tid);
        uint256 action = TaskStorage().getAction(tid);

        offline(node);
        Task().acceptTaskTimeout(tid);

        if(Add == action) {
            address[] memory nodes = selectNodes(size, 1);
            require(1 == nodes.length, "NodeFileHandler: no available node:1"); // TODO check: no require?
            Task().issueTask(Add, owner, cid, nodes[0], size);
        }
    }

    function taskTimeout(address addr, uint256 tid) external {
        mustAddress(CONTRACT_MONITOR);
        // TODO: Node should verify the taskAcceptTimeout Report by Monitor
        address node = TaskStorage().getNode(tid);
        address owner = TaskStorage().getOwner(tid);
        string memory cid = TaskStorage().getCid(tid);
        uint256 size = TaskStorage().getSize(tid);
        uint256 action = TaskStorage().getAction(tid);

        offline(node);
        Task().taskTimeout(tid);

        if(Add == action) {
            uint256 maxAddFileFailedCount = Setting().getMaxAddFileFailedCount();
            uint256 addFileFailedCount = Storage().upAddFileFailedCount(cid);
            if(addFileFailedCount >= maxAddFileFailedCount) {
                UserFileHandler().callbackFailAddFile(owner, cid);
                return;
            }

            address[] memory nodes = selectNodes(size, 1);
            require(1 == nodes.length, "NodeFileHandler: no available node:1"); // TODO check: no require?
            Task().issueTask(Add, owner, cid, nodes[0], size);
        }
    }

    //////////////////////// private functions ////////////////////////
    function selectNodes(uint256 size, uint256 count) private view returns (address[] memory) {
        address[] memory onlineNodeAddresses;
        bool finish;
        (onlineNodeAddresses, finish) = StorageViewer().getAllOnlineNodeAddresses(50, 1);

        if(onlineNodeAddresses.length <= count) {
            return onlineNodeAddresses;
        } else {
            address[] memory nodes = new address[](count);
            for(uint256 i=0; i<count; i++) {
                if(StorageViewer().getStorageFree(onlineNodeAddresses[i]) >= size) {
                    nodes[i] = onlineNodeAddresses[i];
                }
            }
            return nodes;
        }
    }

    function offline(address addr) private {
        mustAddress(CONTRACT_CHAIN_STORAGE);

        uint256 status = StorageViewer().getStatus(addr);
        require(NodeOnline == status, contractName.concat(": wrong status"));

        Storage().setStatus(addr, NodeMaintain);

        if(StorageViewer().isNodeOnline(addr)) {
            Storage().deleteOnlineNode(addr);
        }

        emit NodeStatusChanged(addr, status, NodeMaintain);
    }
}
