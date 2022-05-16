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
import "./interfaces/INodeTaskHandler.sol";

contract NodeTaskHandler is Importable, ExternalStorable, INodeTaskHandler {
    using NodeSelector for address;
    using SafeMath for uint256;

    event NodeStatusChanged(address indexed addr, uint256 from, uint256 to);

    constructor(IResolver _resolver) public Importable(_resolver) {
        setContractName(CONTRACT_NODE_TASK_HANDLER);
        imports = [
            CONTRACT_SETTING,
            CONTRACT_TASK,
            CONTRACT_FILE
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

    function File() private view returns (IFile) {
        return IFile(requireAddress(CONTRACT_FILE));
    }

    function finishTask(address addr, uint256 tid, uint256 size) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);

        address owner;
        uint256 action;
        address node;
        string memory cid;

        (owner, action, node, cid) = Task().getTask(tid); // TODO check getTask
        require(addr == node, "NC:nt"); // node have no this task

        if(Add == action) {
            File().onNodeAddFileFinish(node, owner, cid, size);
            Storage().useStorage(node, size);
            Storage().resetAddFileFailedCount(cid);
        } else if(Delete == action) {
            File().onNodeDeleteFileFinish(node, owner, cid);
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
        (address owner, uint256 action, address node, string memory cid) = Task().getTask(tid);
        require(addr == node, "NodeFileHandler: node have no this task");
        require(Add == action, "NodeFileHandler: only Add task can fail");

        uint256 maxAddFileFailedCount = Setting().getMaxAddFileFailedCount();
        uint256 addFileFailedCount = Storage().upAddFileFailedCount(cid);
        if(addFileFailedCount >= maxAddFileFailedCount) {
            File().onAddFileFail(owner, cid);
            return;
        }

        if(Add == action) {
            _retryAddFileTask(owner, cid);
        }

        Task().failTask(tid);
    }

    function reportAcceptTaskTimeout(address addr, uint256 tid) external {
        mustAddress(CONTRACT_MONITOR);
        // TODO: Node should verify the taskAcceptTimeout Report by Monitor
        (, uint256 action, address node, string memory cid) = Task().getTask(tid);

        _offline(node);
        Task().acceptTaskTimeout(tid);

        if(Add == action) {
            _retryAddFileTask(owner, cid);
        }
    }

    function reportTaskTimeout(address addr, uint256 tid) external {
        mustAddress(CONTRACT_MONITOR);
        // TODO: Node should verify the taskAcceptTimeout Report by Monitor
        (address owner, uint256 action, address node, string memory cid) = Task().getTask(tid);

        _offline(node);
        Task().taskTimeout(tid);

        if(Add == action) {
            uint256 maxAddFileFailedCount = Setting().getMaxAddFileFailedCount();
            uint256 addFileFailedCount = Storage().upAddFileFailedCount(cid);
            if(addFileFailedCount >= maxAddFileFailedCount) {
                File().onAddFileFail(owner, cid);
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
