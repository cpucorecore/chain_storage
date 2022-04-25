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
        setContractName(CONTRACT_FILE);
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

    function register(address addr, uint256 space, string calldata ext) external {
        require(false == Storage().exist(addr), contractName.concat(": node exist"));
        require(bytes(ext).length <= Setting().getMaxNodeExtLength(), contractName.concat(": ext too long"));
        require(space > 0, contractName.concat(": space must > 0"));

        Storage().newNode(addr, space, ext);
    }

    function deRegister(address addr) private {
        checkExist(addr);
        Storage().deleteNode(addr);
    }

    function exist(address addr) external view returns (bool) {
        return Storage().exist(addr);
    }

    function getExt(address addr) external view returns (string memory) {
        return Storage().getExt(addr);
    }

    function setExt(address addr, string calldata ext) external {
        checkExist(addr);
        require(bytes(ext).length <= Setting().getMaxNodeExtLength(), contractName.concat(": ext too long"));
        Storage().setExt(addr, ext);
    }

    function online(address addr) external {
        checkExist(addr);

        INodeStorage.Status status = Storage().getStatus(addr);
        require(INodeStorage.Status.Registered == status ||
                INodeStorage.Status.Maintain == status ||
                INodeStorage.Status.Offline == status,
            contractName.concat(": wrong status"));

        INodeStorage.TasksProgress memory tasksProgress = Storage().getTasksProgress(addr);
        require(tasksProgress.currentTime == tasksProgress.targetTime, contractName.concat("must finish all task"));
        Storage().setStatus(addr, INodeStorage.Status.Online);
    }

    function offline(address addr) private {
        checkExist(addr);
        INodeStorage.Status status = Storage().getStatus(addr);
        require(INodeStorage.Status.Online == status, contractName.concat(": wrong status"));
        Storage().setStatus(addr, INodeStorage.Status.Offline);
        uint256 offlineCount = Storage().getOfflineCount(addr);
        Storage().setOfflineCount(addr, offlineCount.add(1));
    }

    function maintain(address addr) external {
        checkExist(addr);
        INodeStorage.Status status = Storage().getStatus(addr);
        require(INodeStorage.Status.Online == status, contractName.concat(": wrong status"));
        Storage().setStatus(addr, INodeStorage.Status.Maintain);
        uint256 maintainCount = Storage().getMaintainCount(addr);
        Storage().setMaintainCount(addr, maintainCount.add(1));
    }

    function addFile(address owner, string calldata cid, uint256 size) external {
        uint256 replica = Setting().getReplica();
        address[] memory nodeAddrs = selectNodes(size, replica);
        require(nodeAddrs.length != replica, contractName.concat(": no available node"));

        for(uint256 i=0; i<nodeAddrs.length; i++) {
            Task().issueTask(ITaskStorage.Action.Add, owner, cid, nodeAddrs[i], size);
        }
    }

    function getAllNodeAddresses(uint256 pageSize, uint256 pageNumber) external view returns (address[] memory, Paging.Page memory) {
        return Storage().getAllNodeAddresses(pageSize, pageNumber);
    }

    function getAllOnlineNodeAddresses(uint256 pageSize, uint256 pageNumber) external view returns (address[] memory, Paging.Page memory) {
        return Storage().getAllOnlineNodeAddresses(pageSize, pageNumber);
    }

    function getNodeCids(address addr, uint256 pageSize, uint256 pageNumber) external view returns (string[] memory, Paging.Page memory) {
        return Storage().getNodeCids(addr, pageSize, pageNumber);
    }

    function finishTask(uint256 tid) external {
        ITaskStorage.TaskItem memory task = Task().getTaskItem(tid);
        if(ITaskStorage.Action.Add == task.action) {
            File().fileAdded(task.node, task.owner, task.cid);
            useStorage(task.node, task.size);
        } else if(ITaskStorage.Action.Delete == task.action) {
            File().fileDeleted(task.node, task.owner, task.cid);
            freeStorage(task.node, task.size);
        }

        uint256 taskCreateTime = Task().getCreateTime(tid);
        uint256 nodeTime = Storage().getTasksProgressCurrentTime(task.node);
        if (taskCreateTime > nodeTime) {
            Storage().setTasksProgressCurrentTime(task.node, taskCreateTime);
        }

        Storage().setTaskFinishCount(task.node, Storage().getTaskFinishCount(task.node).add(1));
        Task().finishTask(tid);
    }

    function failTask(uint256 tid) external {
        ITaskStorage.TaskItem memory task = Task().getTaskItem(tid);
        Storage().setTaskFailCount(task.node, Storage().getTaskFailCount(task.node).add(1));
        Task().failTask(tid);

        if(ITaskStorage.Action.Add == task.action) {
            uint256 maxAddFileFailedCount = Setting().getMaxAddFileFailedCount();
            uint256 addFileFailedCount = Storage().getAddFileFailedCount(task.cid);
            if(addFileFailedCount >= maxAddFileFailedCount) {
                User().failAddFile(task.owner, task.cid);
                return;
            }
            Storage().setAddFileFailedCount(task.cid, addFileFailedCount.add(1));

            address[] memory addrs = selectNodes(task.size, 1);
            require(1 == addrs.length, contractName.concat(": no available node:1"));
            Task().issueTask(ITaskStorage.Action.Add, task.owner, task.cid, addrs[0], task.size);
        }
    }

    function taskAcceptTimeout(uint256 tid) external {
        ITaskStorage.TaskItem memory task = Task().getTaskItem(tid);
        Storage().setTaskAcceptTimeoutCount(task.node, Storage().getTaskAcceptTimeoutCount(task.node).add(1));

        offline(task.node);
        Task().TaskAcceptTimeout(tid);

        if(ITaskStorage.Action.Add == task.action) {
            address[] memory addrs = selectNodes(task.size, 1);
            require(1 == addrs.length, contractName.concat(": no available node:1"));
            Task().issueTask(ITaskStorage.Action.Add, task.owner, task.cid, addrs[0], task.size);
        }
    }

    function taskTimeout(uint256 tid) external {
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

            address[] memory addrs = selectNodes(task.size, 1);
            require(1 == addrs.length, contractName.concat(": no available node:1"));
            Task().issueTask(ITaskStorage.Action.Add, task.owner, task.cid, addrs[0], task.size);
        }
    }


    //////////////////////// private functions ////////////////////////
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
        INodeStorage.StorageInfo memory storageInfo = Storage().getStorageInfo(node);
        require(size > 0 && storageInfo.used.add(size) <= storageInfo.total, contractName.concat(": space not enough"));
        Storage().setStorageUsed(node, storageInfo.used.add(size));
    }

    function freeStorage(address node, uint256 size) private {
        INodeStorage.StorageInfo memory storageInfo = Storage().getStorageInfo(node);
        require(size > 0 && size <= storageInfo.used, contractName.concat("free size can not big than used size"));
        Storage().setStorageUsed(node, storageInfo.used.sub(size));
    }
}