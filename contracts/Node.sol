pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import "./base/Importable.sol";
import "./base/ExternalStorable.sol";
import "./interfaces/INode.sol";
import "./interfaces/storages/INodeStorage.sol";
import "./interfaces/ITask.sol";
import "./interfaces/ISetting.sol";
import "./interfaces/IFile.sol";

contract Node is Importable, ExternalStorable, INode {
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

    function register(address addr, uint256 space, string calldata ext) external {
        require(false == Storage().exist(addr), contractName.concat(": node exist"));
        require(bytes(ext).length <= Setting().maxNodeExtLength(), contractName.concat(": ext too long"));
        require(space > 0, contractName.concat(": space must > 0"));

        Storage().newNode(addr, space, ext);
    }

    function deRegister(address addr) public {
        // TODO check
        checkExist(addr);
        Storage().deleteNode(addr);
    }

    function getExt(address addr) external view returns (string memory) {
        checkExist(addr);
        return Storage().getExt(addr);
    }

    function setExt(address addr, string calldata ext) external {
        checkExist(addr);
        require(bytes(ext).length <= Setting().maxNodeExtLength(), contractName.concat(": ext too long"));
        Storage().setExt(addr, ext);
    }

    function online(address addr) external {
        checkExist(addr);

        INodeStorage.Status status = Storage().getStatus(addr);
        require(INodeStorage.Status.Registered == status ||
                INodeStorage.Status.Maintain == status ||
                INodeStorage.Status.Offline == status,
            contractName.concat(": wrong status"));
        INodeStorage.TaskBlock memory taskBlock = Storage().getTaskBlock(addr);
        require(taskBlock.current == taskBlock.target, contractName.concat("must finish all task"));
        Storage().setStatus(addr, INodeStorage.Status.Online);
    }

    function offline(address addr) private {
        checkExist(addr);
        INodeStorage.Status status = Storage().getStatus(addr);
        require(INodeStorage.Status.Online == status, contractName.concat(": wrong status"));
        Storage().setStatus(addr, INodeStorage.Status.Offline);
        uint256 offlineCount = Storage().getOfflineCount(addr).add(1);
        Storage().setOfflineCount(addr, offlineCount);
    }

    function maintain(address addr) public {
        checkExist(addr);
        INodeStorage.Status status = Storage().getStatus(addr);
        require(INodeStorage.Status.Online == status, contractName.concat(": wrong status"));
        Storage().setStatus(addr, INodeStorage.Status.Maintain);
        uint256 maintainCount = Storage().getMaintainCount(addr).add(1);
        Storage().setMaintainCount(addr, maintainCount);
    }

    function addFile(string memory cid, uint256 size, uint256 duration) public {
        uint256 replica = Setting().getReplica();
        address[] memory nodeAddrs = selectNodes(size, replica);
        require(nodeAddrs.length != replica, contractName.concat(": no available node"));

        for(uint256 i=0; i<nodeAddrs.length; i++) {
            Task().issueTaskAdd(cid, nodeAddrs[i], size, duration);
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

    function taskAddFileFinished(uint256 tid, bool skip) public {
        ITaskStorage.TaskItem memory task = Task().getTask(tid);
        require(task.exist, contractName.concat(": tid not exist"));
        require(ITaskStorage.Status.Accepted == task.status, contractName.concat(": wrong status"));

        if(ITaskStorage.Action.Add == task.action) {
            File().fileAdded(task.cid, task.node);
            // TODO useSpace(task.size)
        } else if(ITaskStorage.Action.Delete == task.action) {
            File().fileDeleted(task.cid, task.node);
            // TODO freeSpace(task.size)
        }

        // TODO count task finished

        Task().finishTask(tid);
    }

    function taskFailed(uint256 tid) public {
        ITaskStorage.TaskItem memory task = Task().task(tid);

        require(task.exist, contractName.concat(": tid not exist"));
        require(ITaskStorage.Status.Accepted == task.status, contractName.concat(": wrong status"));

        if(ITaskStorage.Action.Add == task.action) {
            File().fileAdded(task.cid, task.node);
        } else if(ITaskStorage.Action.Delete == task.action) {
            File().fileDeleted(task.cid, task.node);
        }

        // TODO count task failed
        Task().failTask(tid);
    }

    function taskAcceptTimeout(uint256 tid) external {
        ITaskStorage.TaskItem memory task = Task().task(tid);

        require(task.exist, contractName.concat(": tid not exist"));
        require(ITaskStorage.Status.Created == task.status, contractName.concat(": wrong status"));

        if(ITaskStorage.Action.Add == task.action) {
            Storage().upTaskAddAcceptTimeoutCount(task.node);
        } else if(ITaskStorage.Action.Delete == task.action) {
            Storage().upTaskDeleteAcceptTimeoutCount(task.node);
        }

        if(Storage().totalTaskTimeoutCount(task.node) > Setting().maxTimeout()) {
            offline(task.node);
        }

        if(ITaskStorage.Action.Add == task.action) {
            address[] memory addrs = selectNodes(task.size, 1);
            require(1 == addrs.length, contractName.concat(": no available node:1"));
            Task().issueTaskAdd(task.cid, addrs[0], task.size, task.duration);
        }
    }

    function taskTimeout(uint256 tid) external {
        ITaskStorage.TaskItem memory task = Task().task(tid);

        require(task.exist, contractName.concat(": tid not exist"));
        require(ITaskStorage.Status.Accepted == task.status, contractName.concat(": wrong status"));

        if(ITaskStorage.Action.Add == task.action) {
            Storage().upTaskAddTimeoutCount(task.node);
        } else if(ITaskStorage.Action.Delete == task.action) {
            Storage().upTaskDeleteTimeoutCount(task.node);
        }

        if(Storage().totalTaskTimeoutCount(task.node) > Setting().maxTimeout()) {
            offline(task.node);
        }

        if(ITaskStorage.Action.Add == task.action) {
            address[] memory addrs = selectNodes(task.size, 1);
            require(1 == addrs.length, contractName.concat(": no available node:1"));
            Task().issueTaskAdd(task.cid, addrs[0], task.size, task.duration);
        }
    }

    function selectNodes(uint256 size, uint256 count) private returns (address[] memory) {
        address[] memory onlineNodeAddresses;
        Paging.Page memory page;
        (onlineNodeAddresses, page) = Storage().onlineNodeAddresses(50, 1);
        if(onlineNodeAddresses.length <= count) {
            return onlineNodeAddresses;
        } else {
            address[] memory nodes = new address[](count);
            for(uint256 i=0; i<count; i++) {
                if(Storage().freeSpace(onlineNodeAddresses[i]) >= size) {
                    nodes[i] = onlineNodeAddresses[i];
                }
            }
            return nodes;
        }

        // TODO select by socre
    }

    function feedNode(uint256 food) private {

    }

    function checkExist(address addr) private {
        require(Storage().exist(addr), contractName.concat(": node not exist"));
    }
    ////////////////////////////////////////////
    function setStatus(address addr, Status status) public {
        nodes[addr].status = status;
        if(Status.Online == status) {
            onlineNodeAddrs.add(addr);
        } else if(Status.Maintain == status) {
            onlineNodeAddrs.remove(addr);
            nodes[addr].serviceInfo.maintainCount = nodes[addr].serviceInfo.maintainCount.add(1);
        } else if(Status.Offline == status) {
            onlineNodeAddrs.remove(addr);
            nodes[addr].serviceInfo.offlineCount = nodes[addr].serviceInfo.offlineCount.add(1);
        } else if(Status.DeRegistered == status) {
            onlineNodeAddrs.remove(addr);
        }
    }
}