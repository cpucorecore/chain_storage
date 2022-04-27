pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import "../interfaces/storages/ITaskStorage.sol";
import "./ExternalStorage.sol";

contract TaskStorage is ExternalStorage, ITaskStorage {
    uint256 private tid;
    mapping(uint256=>TaskItem) private tid2taskItem;
    mapping(uint256=>StatusInfo) private tid2statusInfo;
    mapping(uint256=>AddFileTaskProgress) private tid2addFileTaskProgress;

    function newTask(
        address owner,
        Action action,
        string calldata cid,
        uint256 size,
        address node,
        uint256 createBlock,
        uint256 createTime
    ) external returns (uint256) {
        tid = tid.add(1);

        tid2taskItem[tid] = TaskItem(owner, action, node, size, cid, createBlock, true);
        tid2statusInfo[tid] = StatusInfo(ITaskStorage.Status.Created, createTime, 0, 0, 0, 0, 0, true);
        if(ITaskStorage.Action.Add == action) {
            tid2addFileTaskProgress[tid] = AddFileTaskProgress(0, 0, 0, 0, 0, 0, true);
        }

        return tid;
    }

    function exist(uint256 tid) external view returns (bool) {
        return tid2taskItem[tid].exist && tid2statusInfo[tid].exist;
    }

    function getCurrentTid() external view returns (uint256) {
        return tid;
    }

    function getTaskItem(uint256 tid) external view returns (TaskItem memory) {
        return tid2taskItem[tid];
    }

    function getAction(uint256 tid) external view returns (Action) {
        return tid2taskItem[tid].action;
    }

    function getCreateBlockNumber(uint256 tid) external view returns (uint256) {
        return tid2taskItem[tid].createBlockNumber;
    }

    function getStatus(uint256 tid) external view returns (Status) {
        return tid2statusInfo[tid].status;
    }

    function getCreateTime(uint256 tid) external view returns (uint256) {
        return tid2statusInfo[tid].createTime;
    }

    function getStatusAndTime(uint256 tid) external view returns (Status, uint256) {
        uint256 time = 0;
        Status status = tid2statusInfo[tid].status;
        if(ITaskStorage.Status.Created == status) {
            time = tid2statusInfo[tid].createTime;
        } else if(ITaskStorage.Status.Accepted == status) {
            time = tid2statusInfo[tid].acceptTime;
        } else if(ITaskStorage.Status.AcceptTimeout == status) {
            time = tid2statusInfo[tid].acceptTimeoutTime;
        } else if(ITaskStorage.Status.Finished == status) {
            time = tid2statusInfo[tid].finishTime;
        } else if(ITaskStorage.Status.Failed == status) {
            time = tid2statusInfo[tid].failTime;
        } else if(ITaskStorage.Status.Timeout == status) {
            time = tid2statusInfo[tid].timeoutTime;
        }
        return (status, time);
    }

    function getStatusInfo(uint256 tid) external view returns (StatusInfo memory) {
        return tid2statusInfo[tid];
    }

    function setStatusAndTime(uint256 tid, ITaskStorage.Status status, uint256 time) external {
        tid2statusInfo[tid].status = status;
        if(ITaskStorage.Status.Accepted == status) {
            tid2statusInfo[tid].acceptTime = time;
        } else if(ITaskStorage.Status.AcceptTimeout == status) {
            tid2statusInfo[tid].acceptTimeoutTime = time;
        } else if(ITaskStorage.Status.Finished == status) {
            tid2statusInfo[tid].finishTime = time;
        } else if(ITaskStorage.Status.Failed == status) {
            tid2statusInfo[tid].failTime = time;
        } else if(ITaskStorage.Status.Timeout == status) {
            tid2statusInfo[tid].timeoutTime = time;
        }
    }

    function getAddFileTaskProgress(uint256 tid) external view returns (AddFileTaskProgress memory) {
        return tid2addFileTaskProgress[tid];
    }

    function setAddFileTaskProgress(uint256 tid, uint256 time, uint256 size) external {
        tid2addFileTaskProgress[tid].time = time;
        tid2addFileTaskProgress[tid].lastSize = tid2addFileTaskProgress[tid].currentSize;
        tid2addFileTaskProgress[tid].currentSize = size;
    }
}
