pragma solidity ^0.5.2;

import "./base/Importable.sol";
import "./base/ExternalStorable.sol";
import "./lib/SafeMath.sol";
import "./lib/NodeSelector.sol";
import "./interfaces/storages/INodeStorage.sol";
import "./interfaces/ISetting.sol";
import "./interfaces/ITask.sol";
import "./interfaces/storages/ITaskStorage.sol";
import "./interfaces/IFile.sol";
import "./interfaces/INodeCallback.sol";
import "./interfaces/IUserCallback.sol";

contract NodeFileHandler is Importable, ExternalStorable, INodeCallback {
    using NodeSelector for address;
    using SafeMath for uint256;

    event NodeStatusChanged(address indexed addr, uint256 from, uint256 to);

    constructor(IResolver _resolver) public Importable(_resolver) {
        setContractName(CONTRACT_NODE_CALLBACK);
        imports = [
            CONTRACT_SETTING,
            CONTRACT_FILE,
            CONTRACT_USER_CALLBACK,
            CONTRACT_TASK
        ];
    }

    function Storage() private view returns (INodeStorage) {
        return INodeStorage(getStorage());
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

    function UserCallback() private view returns (IUserCallback) {
        return IUserCallback(requireAddress(CONTRACT_USER_CALLBACK));
    }

    function finishTask(address addr, uint256 tid, uint256 size) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);

        address owner;
        uint256 action;
        address node;
        string memory cid;

        (owner, action, node, cid) = TaskStorage().getTask(tid); // TODO check getTask
        require(addr == node, "NC:nt"); // node have no this task

        if(Add == action) {
            File().addFileCallback(node, owner, cid, size);
            Storage().useStorage(node, size);
            Storage().resetAddFileFailedCount(cid);
        } else if(Delete == action) {
            File().deleteFileCallback(node, owner, cid);
            Storage().freeStorage(node, size);
        }

        uint256 currentTid = Storage().getMaxFinishedTid(addr);
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
        uint256 action = TaskStorage().getAction(tid);
        require(Add == action, "NodeFileHandler: only Add task can fail");

        uint256 maxAddFileFailedCount = Setting().getMaxAddFileFailedCount();
        uint256 addFileFailedCount = Storage().upAddFileFailedCount(cid);
        if(addFileFailedCount >= maxAddFileFailedCount) {
            UserCallback().callbackFailAddFile(owner, cid);
            return;
        }

        if(Add == action) {
            _retryAddFileTask(owner, cid);
        }

        Task().failTask(tid);
    }

    function taskAcceptTimeout(address addr, uint256 tid) external {
        mustAddress(CONTRACT_MONITOR);
        // TODO: Node should verify the taskAcceptTimeout Report by Monitor
        address node = TaskStorage().getNode(tid);
        address owner = TaskStorage().getOwner(tid);
        string memory cid = TaskStorage().getCid(tid);
        uint256 action = TaskStorage().getAction(tid);

        _offline(node);
        Task().acceptTaskTimeout(tid);

        if(Add == action) {
            _retryAddFileTask(owner, cid);
        }
    }

    function taskTimeout(address addr, uint256 tid) external {
        mustAddress(CONTRACT_MONITOR);
        // TODO: Node should verify the taskAcceptTimeout Report by Monitor
        address node = TaskStorage().getNode(tid);
        address owner = TaskStorage().getOwner(tid);
        string memory cid = TaskStorage().getCid(tid);
        uint256 action = TaskStorage().getAction(tid);

        _offline(node);
        Task().taskTimeout(tid);

        if(Add == action) {
            uint256 maxAddFileFailedCount = Setting().getMaxAddFileFailedCount();
            uint256 addFileFailedCount = Storage().upAddFileFailedCount(cid);
            if(addFileFailedCount >= maxAddFileFailedCount) {
                UserCallback().callbackFailAddFile(owner, cid);
                return;
            }
            _retryAddFileTask(owner, cid);
        }
    }

    function _offline(address addr) private {
        mustAddress(CONTRACT_CHAIN_STORAGE);

        uint256 status = Storage().getStatus(addr);
        require(NodeOnline == status, contractName.concat(": wrong status"));

        Storage().setStatus(addr, NodeMaintain);

        if(Storage().isNodeOnline(addr)) {
            Storage().deleteOnlineNode(addr);
        }

        emit NodeStatusChanged(addr, status, NodeMaintain);
    }

    function _retryAddFileTask(address owner, string memory cid) private {
        address[] memory nodes;
        bool success;
        address nodeStorageAddr = getStorage();
        (nodes, success) = nodeStorageAddr.selectNodes(1);
        require(success, "N:no available node"); // TODO check: no require?
        Task().issueTask(Add, owner, cid, nodes[0]);
    }
}
