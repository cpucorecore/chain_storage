pragma solidity ^0.5.2;

import "./base/Importable.sol";
import "./base/ExternalStorable.sol";
import "./interfaces/INodeFileHandler.sol";
import "./lib/SafeMath.sol";
import "./interfaces/storages/INodeStorage.sol";
import "./interfaces/ISetting.sol";
import "./interfaces/ITask.sol";
import "./interfaces/IFile.sol";
import "./interfaces/IUserFileHandler.sol";
import "./interfaces/IHistory.sol";

contract NodeFileHandler is Importable, ExternalStorable, INodeFileHandler {
    using SafeMath for uint256;

    constructor(IResolver _resolver) public Importable(_resolver) {
        setContractName(CONTRACT_NODE_FILE_HANDLER);
        imports = [
        CONTRACT_SETTING,
        CONTRACT_FILE,
        CONTRACT_USER_FILE_HANDLER,
        CONTRACT_TASK,
        CONTRACT_HISTORY
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

    function UserFileHandler() private view returns (IUserFileHandler) {
        return IUserFileHandler(requireAddress(CONTRACT_USER_FILE_HANDLER));
    }

    function History() private view returns (IHistory) {
        return IHistory(requireAddress(CONTRACT_HISTORY));
    }

    function addFile(address owner, string calldata cid, uint256 size) external onlyAddress(CONTRACT_FILE) {
//        uint256 replica = Setting().getReplica();
//        require(0 != replica, contractName.concat(": replica is 0"));
//
//        address[] memory nodeAddrs = selectNodes(size, replica);
//        require(nodeAddrs.length == replica, contractName.concat(": addFile: no available node"));
//
//        for(uint256 i=0; i<nodeAddrs.length; i++) {
//            Task().issueTask(ITaskStorage.Action.Add, owner, cid, nodeAddrs[i], size);
//        }
    }

    function finishTask(address addr, uint256 tid) external onlyAddress(CONTRACT_CHAIN_STORAGE) {
//        address owner;
//        ITaskStorage.Action action;
//        address node;
//        uint256 size;
//        string memory cid;
//
//        (owner, action, node, size, cid) = Task().getTask(tid);
//
//        require(addr == node, contractName.concat(": node have no this task"));
//
//        if(ITaskStorage.Action.Add == action) {
//            File().addFileCallback(node, owner, cid);
//            Storage().useStorage(node, size);
//            History().addNodeAction(addr, tid, IHistory.ActionType.Add, keccak256(bytes(cid)));
//            Storage().setTaskAddFileFinishCount(node, Storage().getTaskAddFileFinishCount(node).add(1));
//            resetAddFileFailedCount(cid);
//            addNodeCid(addr, cid);
//        } else if(ITaskStorage.Action.Delete == action) {
//            File().deleteFileCallback(node, owner, cid);
//            Storage().freeStorage(node, size);
//            Storage().setTaskDeleteFileFinishCount(node, Storage().getTaskDeleteFileFinishCount(node).add(1));
//            History().addNodeAction(addr, tid, IHistory.ActionType.Delete, keccak256(bytes(cid)));
//            removeNodeCid(addr, cid);
//        }
//
//        updateFinishedTid(addr, tid);
//        Task().finishTask(tid);
    }

    function failTask(address addr, uint256 tid) external onlyAddress(CONTRACT_CHAIN_STORAGE) {
        address node = Task().getNode(tid);
        require(addr == node, contractName.concat(": node have no this task"));

        address owner = Task().getOwner(tid);
        string memory cid = Task().getCid(tid);
        uint256 size = Task().getSize(tid);
        ITaskStorage.Action action = Task().getAction(tid);
        require(ITaskStorage.Action.Add == action, contractName.concat(": only addFile task can fail"));

        Storage().setTaskAddFileFailCount(node, Storage().getTaskAddFileFailCount(node).add(1));

        uint256 maxAddFileFailedCount = Setting().getMaxAddFileFailedCount();
        uint256 addFileFailedCount = Storage().getAddFileFailedCount(cid).add(1);
        Storage().setAddFileFailedCount(cid, addFileFailedCount);
        if(addFileFailedCount >= maxAddFileFailedCount) {
            UserFileHandler().callbackFailAddFile(owner, cid);
            return;
        }

        address[] memory nodes = selectNodes(size, 1);
        require(1 == nodes.length, contractName.concat(": no available node:1")); // TODO check: no require?
        Task().issueTask(ITaskStorage.Action.Add, owner, cid, nodes[0], size);

        Task().failTask(tid);
    }

    function taskAcceptTimeout(address addr, uint256 tid) external onlyAddress(CONTRACT_MONITOR) {
        // TODO: Node should verify the taskAcceptTimeout Report by Monitor
        address node = Task().getNode(tid);
        address owner = Task().getOwner(tid);
        string memory cid = Task().getCid(tid);
        uint256 size = Task().getSize(tid);
        ITaskStorage.Action action = Task().getAction(tid);

        Storage().setTaskAcceptTimeoutCount(node, Storage().getTaskAcceptTimeoutCount(node).add(1));

        offline(node);
        Task().acceptTaskTimeout(tid);

        if(ITaskStorage.Action.Add == action) {
            address[] memory nodes = selectNodes(size, 1);
            require(1 == nodes.length, contractName.concat(": no available node:1")); // TODO check: no require?
            Task().issueTask(ITaskStorage.Action.Add, owner, cid, nodes[0], size);
        }
    }

    function taskTimeout(address addr, uint256 tid) external onlyAddress(CONTRACT_MONITOR) {
        // TODO: Node should verify the taskAcceptTimeout Report by Monitor
        address node = Task().getNode(tid);
        address owner = Task().getOwner(tid);
        string memory cid = Task().getCid(tid);
        uint256 size = Task().getSize(tid);
        ITaskStorage.Action action = Task().getAction(tid);

        Storage().setTaskTimeoutCount(node, Storage().getTaskTimeoutCount(node).add(1));

        offline(node);
        Task().taskTimeout(tid);

        if(ITaskStorage.Action.Add == action) {
            uint256 maxAddFileFailedCount = Setting().getMaxAddFileFailedCount();
            uint256 addFileFailedCount = Storage().getAddFileFailedCount(cid);
            if(addFileFailedCount >= maxAddFileFailedCount) {
                return;
            }
            Storage().setAddFileFailedCount(cid, addFileFailedCount.add(1));

            address[] memory nodes = selectNodes(size, 1);
            require(1 == nodes.length, contractName.concat(": no available node:1")); // TODO check: no require?
            Task().issueTask(ITaskStorage.Action.Add, owner, cid, nodes[0], size);
        }
    }

    //////////////////////// private functions ////////////////////////
    function offline(address addr) private {
        checkExist(addr);

        INodeStorage.Status status = Storage().getStatus(addr);
        require(INodeStorage.Status.Online == status, contractName.concat(": wrong status"));
        Storage().setStatus(addr, INodeStorage.Status.Offline);
        if(Storage().isNodeOnline(addr)) {
            Storage().deleteOnlineNode(addr);
        }
        uint256 offlineCount = Storage().getOfflineCount(addr);
        Storage().setOfflineCount(addr, offlineCount.add(1));
    }

    function selectNodes(uint256 size, uint256 count) private view returns (address[] memory) {
        address[] memory onlineNodeAddresses;
        bool finish;
        (onlineNodeAddresses, finish) = Storage().getAllOnlineNodeAddresses(50, 1);

        if(onlineNodeAddresses.length <= count) {
            return onlineNodeAddresses;
        } else {
            address[] memory nodes = new address[](count);
            for(uint256 i=0; i<count; i++) {
                if(Storage().getStorageFree(onlineNodeAddresses[i]) >= size) {
                    nodes[i] = onlineNodeAddresses[i];
                }
            }
            return nodes;
        }
    }

    function checkExist(address addr) private view {
        require(Storage().exist(addr), contractName.concat(": node not exist"));
    }

    function resetAddFileFailedCount(string memory cid) private {
        uint256 addFileFailedCount = Storage().getAddFileFailedCount(cid);
        if(addFileFailedCount > 0) {
            Storage().setAddFileFailedCount(cid, 0);
        }
    }

    function addNodeCid(address addr, string memory cid) private {
        if(!Storage().cidExist(addr, cid)) {
            Storage().addNodeCid(addr, cid);
        }
    }

    function removeNodeCid(address addr, string memory cid) private {
        if(Storage().cidExist(addr, cid)) {
            Storage().removeNodeCid(addr, cid);
        }
    }

    function updateFinishedTid(address addr, uint256 newTid) private {
        uint256 current = Storage().getMaxFinishedTid(addr);
        if(newTid > current) {
            Storage().setMaxFinishedTid(addr, newTid);
        }
    }
}