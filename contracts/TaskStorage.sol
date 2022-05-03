pragma solidity ^0.5.2;
pragma experimental ABIEncoderV2;

import "./storages/ExternalStorage.sol";
import "./interfaces/storages/ITaskStorage.sol";

contract TaskStorage is ExternalStorage, ITaskStorage {
    uint256 private tid;
    mapping(uint256=>TaskItem) private tid2taskItem;
    mapping(uint256=>TaskState) private tid2taskState;
    mapping(uint256=>AddFileTaskProgress) private tid2addFileProgress;
    mapping(address=>uint256) private node2nodeMaxTid;

    constructor(address _manager) public ExternalStorage(_manager) {}

    function exist(uint256 tid) external view returns (bool) {
        return tid2taskItem[tid].exist && tid2taskState[tid].exist;
    }

    function getCurrentTid() external view returns (uint256) {
        return tid;
    }

    function getNodeMaxTid(address addr) external view returns (uint256) {
        return node2nodeMaxTid[addr];
    }

    function isOver(uint256 tid) external view returns (bool) {
        bool over = false;

        if(Action.Add == tid2taskItem[tid].action) {
            over = !(Status.Created == tid2taskState[tid].status || Status.Accepted == tid2taskState[tid].status);
        } else {
            over = (Status.Finished == tid2taskState[tid].status);
        }
        return over;
    }

    function newTask(
        address owner,
        Action action,
        string calldata cid,
        uint256 size,
        address node
    ) external returns (uint256) {
        tid = tid.add(1);

        tid2taskItem[tid] = TaskItem(owner, action, node, size, cid, true);
        tid2taskState[tid] = TaskState(ITaskStorage.Status.Created, block.number, now, 0, 0, 0, 0, 0, true);
        if(ITaskStorage.Action.Add == action) {
            tid2addFileProgress[tid] = AddFileTaskProgress(0, 0, 0, 0, 0, 0, true);
        }

        node2nodeMaxTid[node] = tid;

        return tid;
    }

    function getTask(uint256 tid) external view returns (address, Action, address, uint256, string memory) {
        TaskItem storage task = tid2taskItem[tid];
        return (task.owner, task.action, task.node, task.size, task.cid);
    }

    function getOwner(uint256 tid) external view returns (address) {
        return tid2taskItem[tid].owner;
    }

    function getAction(uint256 tid) external view returns (Action) {
        return tid2taskItem[tid].action;
    }

    function getNode(uint256 tid) external view returns (address) {
        return tid2taskItem[tid].node;
    }

    function getSize(uint256 tid) external view returns (uint256) {
        return tid2taskItem[tid].size;
    }

    function getCid(uint256 tid) external view returns (string memory) {
        return tid2taskItem[tid].cid;
    }

    function getTaskState(uint256 tid) external view returns (Status, uint256, uint256, uint256, uint256, uint256, uint256, uint256) {
        TaskState storage state = tid2taskState[tid];
        return (state.status,
                state.createBlockNumber,
                state.createTime,
                state.acceptTime,
                state.acceptTimeoutTime,
                state.finishTime,
                state.failTime,
                state.timeoutTime);
    }

    function getStatus(uint256 tid) external view returns (Status) {
        return tid2taskState[tid].status;
    }

    function getCreateBlockNumber(uint256 tid) external view returns (uint256) {
        return tid2taskState[tid].createBlockNumber;
    }

    function getCreateTime(uint256 tid) external view returns (uint256) {
        return tid2taskState[tid].createTime;
    }

    function getAcceptTime(uint256 tid) external view returns (uint256) {
        return tid2taskState[tid].acceptTime;
    }

    function getAcceptTimeoutTime(uint256 tid) external view returns (uint256) {
        return tid2taskState[tid].acceptTimeoutTime;
    }

    function getFinishTime(uint256 tid) external view returns (uint256) {
        return tid2taskState[tid].finishTime;
    }

    function getFailTime(uint256 tid) external view returns (uint256) {
        return tid2taskState[tid].failTime;
    }

    function getTimeoutTime(uint256 tid) external view returns (uint256) {
        return tid2taskState[tid].timeoutTime;
    }

    function getStatusAndTime(uint256 tid) external view returns (Status, uint256) {
        uint256 time = 0;
        Status status = tid2taskState[tid].status;
        if(ITaskStorage.Status.Created == status) {
            time = tid2taskState[tid].createTime;
        } else if(ITaskStorage.Status.Accepted == status) {
            time = tid2taskState[tid].acceptTime;
        } else if(ITaskStorage.Status.AcceptTimeout == status) {
            time = tid2taskState[tid].acceptTimeoutTime;
        } else if(ITaskStorage.Status.Finished == status) {
            time = tid2taskState[tid].finishTime;
        } else if(ITaskStorage.Status.Failed == status) {
            time = tid2taskState[tid].failTime;
        } else if(ITaskStorage.Status.Timeout == status) {
            time = tid2taskState[tid].timeoutTime;
        }
        return (status, time);
    }

    function setStatusAndTime(uint256 tid, ITaskStorage.Status status, uint256 time) external {
        tid2taskState[tid].status = status;
        if(ITaskStorage.Status.Accepted == status) {
            tid2taskState[tid].acceptTime = time;
        } else if(ITaskStorage.Status.AcceptTimeout == status) {
            tid2taskState[tid].acceptTimeoutTime = time;
        } else if(ITaskStorage.Status.Finished == status) {
            tid2taskState[tid].finishTime = time;
        } else if(ITaskStorage.Status.Failed == status) {
            tid2taskState[tid].failTime = time;
        } else if(ITaskStorage.Status.Timeout == status) {
            tid2taskState[tid].timeoutTime = time;
        }
    }

    function getAddFileTaskProgress(uint256 tid) external view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        AddFileTaskProgress storage progress = tid2addFileProgress[tid];
        return (progress.time, progress.lastSize, progress.currentSize, progress.size, progress.lastPercentage, progress.currentPercentage);
    }

    function setAddFileTaskProgressBySize(uint256 tid, uint256 time, uint256 size) external {
        tid2addFileProgress[tid].time = time;
        tid2addFileProgress[tid].lastSize = tid2addFileProgress[tid].currentSize;
        tid2addFileProgress[tid].currentSize = size;
    }

    function setAddFileTaskProgressByPercentage(uint256 tid, uint256 time, uint256 percentage) external {
        tid2addFileProgress[tid].time = time;
        tid2addFileProgress[tid].lastPercentage = tid2addFileProgress[tid].currentPercentage;
        tid2addFileProgress[tid].currentPercentage = percentage;
    }
}
