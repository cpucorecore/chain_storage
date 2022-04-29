pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import "./base/Importable.sol";
import "./base/ExternalStorable.sol";
import "./interfaces/INode.sol";
import "./interfaces/storages/INodeStorage.sol";
import "./interfaces/ITask.sol";
import "./interfaces/ISetting.sol";
import "./interfaces/IFile.sol";
import "./interfaces/IUser.sol";

contract Node is Importable, ExternalStorable, INode {
    using SafeMath for uint256;

    constructor(IResolver _resolver) public Importable(_resolver) {
        setContractName(CONTRACT_NODE);
        imports = [
            CONTRACT_SETTING,
            CONTRACT_FILE,
            CONTRACT_USER,
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

    function File() private view returns (IFile) {
        return IFile(requireAddress(CONTRACT_FILE));
    }

    function User() private view returns (IUser) {
        return IUser(requireAddress(CONTRACT_USER));
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
        Storage().deleteNode(addr);
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

    function getStorageSpaceInfo(address addr) external view returns (INodeStorage.StorageSpaceInfo memory) {
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
        Storage().addOnlineNode(addr); // TODO check dedup
    }

    function maintain(address addr) external {
        checkExist(addr);

        INodeStorage.Status status = Storage().getStatus(addr);
        require(INodeStorage.Status.Online == status, contractName.concat(": wrong status"));

        Storage().setStatus(addr, INodeStorage.Status.Maintain);
        uint256 maintainCount = Storage().getMaintainCount(addr);
        Storage().setMaintainCount(addr, maintainCount.add(1));
    }

    function getAllNodeAddresses() external view returns (address[] memory) {
        return Storage().getAllNodeAddresses();
    }

    function getAllNodeAddresses(uint256 pageSize, uint256 pageNumber) external view returns (address[] memory, Paging.Page memory) {
        return Storage().getAllNodeAddresses(pageSize, pageNumber);
    }

    function getAllOnlineNodeAddresses() external view returns (address[] memory) {
        return Storage().getAllOnlineNodeAddresses();
    }

    function getAllOnlineNodeAddresses(uint256 pageSize, uint256 pageNumber) external view returns (address[] memory, Paging.Page memory) {
        return Storage().getAllOnlineNodeAddresses(pageSize, pageNumber);
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
        ITaskStorage.TaskItem memory task = Task().getTaskItem(tid);
        require(addr == task.node, contractName.concat(": node have no this task"));

        if(ITaskStorage.Action.Add == task.action) {
            File().addFileCallback(task.node, task.owner, task.cid);
            useStorage(task.node, task.size);

            uint256 addFileFailedCount = Storage().getAddFileFailedCount(task.cid);
            if(addFileFailedCount > 0) {
                Storage().setAddFileFailedCount(task.cid, 0);
            }

            Storage().setTaskAddFileFinishCount(task.node, Storage().getTaskAddFileFinishCount(task.node).add(1));
        } else if(ITaskStorage.Action.Delete == task.action) {
            File().deleteFileCallback(task.node, task.owner, task.cid);
            freeStorage(task.node, task.size);
            Storage().setTaskDeleteFileFinishCount(task.node, Storage().getTaskDeleteFileFinishCount(task.node).add(1));
        }

        updateFinishedTid(addr, tid);
        Task().finishTask(tid);
    }

    function failTask(address addr, uint256 tid) external {
        ITaskStorage.TaskItem memory task = Task().getTaskItem(tid);
        require(addr == task.node, contractName.concat(": node have no this task"));
        require(ITaskStorage.Action.Add == task.action, contractName.concat(": only addFile task can fail"));

        Storage().setTaskAddFileFailCount(task.node, Storage().getTaskAddFileFailCount(task.node).add(1));

        uint256 maxAddFileFailedCount = Setting().getMaxAddFileFailedCount();
        uint256 addFileFailedCount = Storage().getAddFileFailedCount(task.cid).add(1);
        Storage().setAddFileFailedCount(task.cid, addFileFailedCount);
        if(addFileFailedCount >= maxAddFileFailedCount) {
            User().callbackFailAddFile(task.owner, task.cid);
            return;
        }

        address[] memory nodes = selectNodes(task.size, 1);
        require(1 == nodes.length, contractName.concat(": no available node:1")); // TODO check: no require?
        Task().issueTask(ITaskStorage.Action.Add, task.owner, task.cid, nodes[0], task.size);

        Task().failTask(tid);
    }

    function taskAcceptTimeout(uint256 tid) external { // TODO: monitor addr?
        ITaskStorage.TaskItem memory task = Task().getTaskItem(tid);
        Storage().setTaskAcceptTimeoutCount(task.node, Storage().getTaskAcceptTimeoutCount(task.node).add(1));

        offline(task.node);
        Task().TaskAcceptTimeout(tid);

        if(ITaskStorage.Action.Add == task.action) {
            address[] memory nodes = selectNodes(task.size, 1);
            require(1 == nodes.length, contractName.concat(": no available node:1")); // TODO check: no require?
            Task().issueTask(ITaskStorage.Action.Add, task.owner, task.cid, nodes[0], task.size);
        }
    }

    function taskTimeout(uint256 tid) external { // TODO: monitor addr?
        ITaskStorage.TaskItem memory task = Task().getTaskItem(tid);
        Storage().setTaskTimeoutCount(task.node, Storage().getTaskTimeoutCount(task.node).add(1));

        offline(task.node);
        Task().TaskTimeout(tid);

        if(ITaskStorage.Action.Add == task.action) {
            uint256 maxAddFileFailedCount = Setting().getMaxAddFileFailedCount();
            uint256 addFileFailedCount = Storage().getAddFileFailedCount(task.cid);
            if(addFileFailedCount >= maxAddFileFailedCount) {
                return;
            }
            Storage().setAddFileFailedCount(task.cid, addFileFailedCount.add(1));

            address[] memory nodes = selectNodes(task.size, 1);
            require(1 == nodes.length, contractName.concat(": no available node:1")); // TODO check: no require?
            Task().issueTask(ITaskStorage.Action.Add, task.owner, task.cid, nodes[0], task.size);
        }
    }

    function getNodeCids(address addr) external view returns (string[] memory) {
        return Storage().getNodeCids(addr);
    }

    function getNodeCids(address addr, uint256 pageSize, uint256 pageNumber) external view returns (string[] memory, Paging.Page memory) {
        return Storage().getNodeCids(addr, pageSize, pageNumber);
    }

    function getTotalNodeNumber() external view returns (uint256) {
        return Storage().getTotalNodeNumber();
    }

    function getTotalOnlineNodeNumber() external view returns (uint256) {
        return Storage().getTotalOnlineNodeNumber();
    }

    //////////////////////// private functions ////////////////////////
    function offline(address addr) private {
        checkExist(addr);

        INodeStorage.Status status = Storage().getStatus(addr);
        require(INodeStorage.Status.Online == status, contractName.concat(": wrong status"));
        Storage().setStatus(addr, INodeStorage.Status.Offline);
        Storage().deleteOnlineNode(addr);  // TODO check exist
        uint256 offlineCount = Storage().getOfflineCount(addr);
        Storage().setOfflineCount(addr, offlineCount.add(1));
    }

    function selectNodes(uint256 size, uint256 count) private returns (address[] memory) {
        address[] memory onlineNodeAddresses;
        Paging.Page memory page;
        (onlineNodeAddresses, page) = Storage().getAllOnlineNodeAddresses(50, 1);

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

    function useStorage(address node, uint256 size) private {
        INodeStorage.StorageSpaceInfo memory storageSpaceInfo = Storage().getStorageSpaceInfo(node);
        require(size > 0 && storageSpaceInfo.used.add(size) <= storageSpaceInfo.total, contractName.concat(": space not enough"));
        Storage().setStorageUsed(node, storageSpaceInfo.used.add(size));
    }

    function freeStorage(address node, uint256 size) private {
        INodeStorage.StorageSpaceInfo memory storageSpaceInfo = Storage().getStorageSpaceInfo(node);
        require(size > 0 && size <= storageSpaceInfo.used, contractName.concat("free size can not big than used size"));
        Storage().setStorageUsed(node, storageSpaceInfo.used.sub(size));
    }
}
