pragma solidity ^0.5.2;
pragma experimental ABIEncoderV2;

import "./base/Importable.sol";
import "./base/ExternalStorable.sol";
import "./interfaces/INode.sol";
import "./interfaces/storages/INodeStorage.sol";
import "./interfaces/ITask.sol";
import "./interfaces/ISetting.sol";
import "./interfaces/IFile.sol";
import "./interfaces/IUser.sol";
import "./interfaces/IHistory.sol";

contract Node is Importable, ExternalStorable, INode {
    using SafeMath for uint256;

    constructor(IResolver _resolver) public Importable(_resolver) {
        setContractName(CONTRACT_NODE);
        imports = [
            CONTRACT_SETTING,
            CONTRACT_FILE,
            CONTRACT_USER,
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

    function User() private view returns (IUser) {
        return IUser(requireAddress(CONTRACT_USER));
    }

    function History() private view returns (IHistory) {
        return IHistory(requireAddress(CONTRACT_HISTORY));
    }

    function exist(address addr) external view returns (bool) {
        return Storage().exist(addr);
    }

    function register(address addr, uint256 space, string calldata ext) external {
        require(!Storage().exist(addr), contractName.concat(": node exist"));
        require(bytes(ext).length <= Setting().getMaxNodeExtLength(), contractName.concat(": ext too long"));
        require(space > 0, contractName.concat(": space must > 0"));

        Storage().newNode(addr, space, ext);
    }

    function deRegister(address addr) external {
        checkExist(addr);
        require(0 == Storage().getNodeCidsNumber(addr), contractName.concat(": files not empty"));
        INodeStorage.Status status = Storage().getStatus(addr);
        require(INodeStorage.Status.Registered == status ||
                INodeStorage.Status.Maintain == status,
            contractName.concat(": can do deRegister only in [Registered/Maintain] status"));

        Storage().deleteNode(addr);
    }

    function getStatus(address addr) external view returns (INodeStorage.Status) {
        return Storage().getStatus(addr);
    }

    function getExt(address addr) external view returns (string memory) {
        return Storage().getExt(addr);
    }

    function setExt(address addr, string calldata ext) external {
        checkExist(addr);
        require(bytes(ext).length <= Setting().getMaxNodeExtLength(), contractName.concat(": node ext too long"));
        Storage().setExt(addr, ext);
    }

    function changeSpace(address addr, uint256 space) external {
        checkExist(addr);
        require(space >= Storage().getStorageUsed(addr), contractName.concat(": can not little than storage used"));
        Storage().setStorageTotal(addr, space);
    }

    function getStorageSpaceInfo(address addr) external view returns (uint256, uint256) { // (used, total)
        return Storage().getStorageSpaceInfo(addr);
    }

    function online(address addr) external {
        checkExist(addr);

        INodeStorage.Status status = Storage().getStatus(addr);
        require(INodeStorage.Status.Registered == status ||
                INodeStorage.Status.Maintain == status ||
                INodeStorage.Status.Offline == status,
            contractName.concat(": wrong status"));

        uint256 maxFinishedTid = Storage().getMaxFinishedTid(addr);
        uint256 nodeMaxTid = Task().getNodeMaxTid(addr);
        require(nodeMaxTid == maxFinishedTid, contractName.concat(": must finish all task"));

        Storage().setStatus(addr, INodeStorage.Status.Online);
        if(!Storage().isNodeOnline(addr)) {
            Storage().addOnlineNode(addr);
        }
    }

    function maintain(address addr) external {
        checkExist(addr);

        INodeStorage.Status status = Storage().getStatus(addr);
        require(INodeStorage.Status.Online == status, contractName.concat(": wrong status"));

        Storage().setStatus(addr, INodeStorage.Status.Maintain);
        uint256 maintainCount = Storage().getMaintainCount(addr);
        Storage().setMaintainCount(addr, maintainCount.add(1));

        if(Storage().isNodeOnline(addr)) {
            Storage().deleteOnlineNode(addr);
        }
    }

    function addFile(address owner, string calldata cid, uint256 size) external {
        uint256 replica = Setting().getReplica();
        require(0 != replica, contractName.concat(": replica is 0"));

        address[] memory nodeAddrs = selectNodes(size, replica);
        require(nodeAddrs.length == replica, contractName.concat(": addFile: no available node"));

        for(uint256 i=0; i<nodeAddrs.length; i++) {
            Task().issueTask(ITaskStorage.Action.Add, owner, cid, nodeAddrs[i], size);
        }
    }

    function updateFinishedTid(address addr, uint256 newTid) private {
        uint256 current = Storage().getMaxFinishedTid(addr);
        if(newTid > current) {
            Storage().setMaxFinishedTid(addr, newTid);
        }
    }

    function finishTask(address addr, uint256 tid) external {
        address owner;
        ITaskStorage.Action action;
        address node;
        uint256 size;
        string memory cid;

        (owner, action, node, size, cid) = Task().getTask(tid);

        require(addr == node, contractName.concat(": node have no this task"));

        if(ITaskStorage.Action.Add == action) {
            File().addFileCallback(node, owner, cid);
            Storage().useStorage(node, size);
            History().addNodeAction(addr, tid, IHistory.ActionType.Add, keccak256(bytes(cid)));
            Storage().setTaskAddFileFinishCount(node, Storage().getTaskAddFileFinishCount(node).add(1));
            resetAddFileFailedCount(cid);
            addNodeCid(addr, cid);
        } else if(ITaskStorage.Action.Delete == action) {
            File().deleteFileCallback(node, owner, cid);
            Storage().freeStorage(node, size);
            Storage().setTaskDeleteFileFinishCount(node, Storage().getTaskDeleteFileFinishCount(node).add(1));
            History().addNodeAction(addr, tid, IHistory.ActionType.Delete, keccak256(bytes(cid)));
            removeNodeCid(addr, cid);
        }

        updateFinishedTid(addr, tid);
        Task().finishTask(tid);
    }

    function failTask(address addr, uint256 tid) external {
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
            User().callbackFailAddFile(owner, cid);
            return;
        }

        address[] memory nodes = selectNodes(size, 1);
        require(1 == nodes.length, contractName.concat(": no available node:1")); // TODO check: no require?
        Task().issueTask(ITaskStorage.Action.Add, owner, cid, nodes[0], size);

        Task().failTask(tid);
    }

    function taskAcceptTimeout(uint256 tid) external { // TODO: monitor addr?
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

    function taskTimeout(uint256 tid) external { // TODO: monitor addr?
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

    function getNodeCidsNumber(address addr) external view returns (uint256) {
        return Storage().getNodeCidsNumber(addr);
    }

    function getNodeCids(address addr) external view returns (string[] memory) {
        return Storage().getNodeCids(addr);
    }

    function getNodeCids(address addr, uint256 pageSize, uint256 pageNumber) external view returns (string[] memory, bool) {
        return Storage().getNodeCids(addr, pageSize, pageNumber);
    }

    function getTotalNodeNumber() external view returns (uint256) {
        return Storage().getTotalNodeNumber();
    }

    function getTotalOnlineNodeNumber() external view returns (uint256) {
        return Storage().getTotalOnlineNodeNumber();
    }

    function getAllNodeAddresses() external view returns (address[] memory) {
        return Storage().getAllNodeAddresses();
    }

    function getAllNodeAddresses(uint256 pageSize, uint256 pageNumber) external view returns (address[] memory, bool) {
        return Storage().getAllNodeAddresses(pageSize, pageNumber);
    }

    function getAllOnlineNodeAddresses() external view returns (address[] memory) {
        return Storage().getAllOnlineNodeAddresses();
    }

    function getAllOnlineNodeAddresses(uint256 pageSize, uint256 pageNumber) external view returns (address[] memory, bool) {
        return Storage().getAllOnlineNodeAddresses(pageSize, pageNumber);
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

    function selectNodes(uint256 size, uint256 count) private returns (address[] memory) {
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

    function checkExist(address addr) private {
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
}
