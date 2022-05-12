pragma solidity ^0.5.2;
pragma experimental ABIEncoderV2;

import "./storages/ExternalStorage.sol";
import "./interfaces/storages/ITaskStorage.sol";

contract TaskStorage is ExternalStorage, ITaskStorage {
    uint256 private currentTid;
    mapping(uint256=>TaskItem) private tid2taskItem;
    mapping(uint256=>TaskState) private tid2taskState;
    mapping(uint256=>AddFileTaskProgress) private tid2addFileProgress;
    mapping(address=>uint256) private node2nodeMaxTid;

    constructor(address _manager) public ExternalStorage(_manager) {}

    function exist(uint256 tid) external view returns (bool) {
        return tid2taskItem[tid].exist && tid2taskState[tid].exist;
    }

    function getCurrentTid() external view returns (uint256) {
        return currentTid;
    }

    function getNodeMaxTid(address addr) external view returns (uint256) {
        return node2nodeMaxTid[addr];
    }

    function isOver(uint256 tid) external view returns (bool) {
        bool over = false;

        if(Add == tid2taskItem[tid].action) {
            over = !(TaskCreated == tid2taskState[tid].status || TaskAccepted == tid2taskState[tid].status);
        } else {
            over = (TaskFinished == tid2taskState[tid].status);
        }
        return over;
    }

    function newTask(
        address owner,
        uint8 action,
        string calldata cid,
        uint256 size,
        address node
    ) external returns (uint256) {
        mustManager(managerName);
        currentTid = currentTid.add(1);

        tid2taskItem[currentTid] = TaskItem(owner, action, node, size, cid, true);
        tid2taskState[currentTid] = TaskState(TaskCreated, block.number, now, 0, 0, 0, 0, 0, true);
        if(Add == action) {
            tid2addFileProgress[currentTid] = AddFileTaskProgress(0, 0, 0, 0, 0, 0, true);
        }

        node2nodeMaxTid[node] = currentTid;

        return currentTid;
    }

    function getTask(uint256 tid) external view returns (address, uint8, address, uint256, string memory) {
        TaskItem storage task = tid2taskItem[tid];
        return (task.owner, task.action, task.node, task.size, task.cid);
    }

    function getOwner(uint256 tid) external view returns (address) {
        return tid2taskItem[tid].owner;
    }

    function getAction(uint256 tid) external view returns (uint8) {
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

    function getTaskState(uint256 tid) external view returns (uint8, uint256, uint256, uint256, uint256, uint256, uint256, uint256) {
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

    function getStatus(uint256 tid) external view returns (uint8) {
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

    function getStatusAndTime(uint256 tid) external view returns (uint8, uint256) {
        uint256 time = 0;
        uint8 status = tid2taskState[tid].status;
        if(TaskCreated == status) {
            time = tid2taskState[tid].createTime;
        } else if(TaskAccepted == status) {
            time = tid2taskState[tid].acceptTime;
        } else if(TaskAcceptTimeout == status) {
            time = tid2taskState[tid].acceptTimeoutTime;
        } else if(TaskFinished == status) {
            time = tid2taskState[tid].finishTime;
        } else if(TaskFailed == status) {
            time = tid2taskState[tid].failTime;
        } else if(TaskTimeout == status) {
            time = tid2taskState[tid].timeoutTime;
        }
        return (status, time);
    }

    function setStatusAndTime(uint256 tid, uint8 status, uint256 time) external {
        mustManager(managerName);
        tid2taskState[tid].status = status;
        if(TaskAccepted == status) {
            tid2taskState[tid].acceptTime = time;
        } else if(TaskAcceptTimeout == status) {
            tid2taskState[tid].acceptTimeoutTime = time;
        } else if(TaskFinished == status) {
            tid2taskState[tid].finishTime = time;
        } else if(TaskFailed == status) {
            tid2taskState[tid].failTime = time;
        } else if(TaskTimeout == status) {
            tid2taskState[tid].timeoutTime = time;
        }
    }

    function getAddFileTaskProgress(uint256 tid) external view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        AddFileTaskProgress storage progress = tid2addFileProgress[tid];
        return (progress.time, progress.lastSize, progress.currentSize, progress.size, progress.lastPercentage, progress.currentPercentage);
    }

    function setAddFileTaskProgressBySize(uint256 tid, uint256 time, uint256 size) external {
        mustManager(managerName);
        tid2addFileProgress[tid].time = time;
        tid2addFileProgress[tid].lastSize = tid2addFileProgress[tid].currentSize;
        tid2addFileProgress[tid].currentSize = size;
    }

    function setAddFileTaskProgressByPercentage(uint256 tid, uint256 time, uint256 percentage) external {
        mustManager(managerName);
        tid2addFileProgress[tid].time = time;
        tid2addFileProgress[tid].lastPercentage = tid2addFileProgress[tid].currentPercentage;
        tid2addFileProgress[tid].currentPercentage = percentage;
    }
}
