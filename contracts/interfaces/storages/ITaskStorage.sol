pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

interface ITaskStorage {
    enum Status {
        Created,
        Accepted,
        AcceptTimeout,
        Finished,
        Failed,
        Timeout
    }

    enum Action {
        Add,
        Delete
    }

    struct TaskItem {
        address owner;
        Action action;
        address node;
        uint256 size;
        string cid;
        bool exist;
    }

    struct StatusInfo {
        Status status;
        uint256 createTime;
        uint256 acceptTime;
        uint256 acceptTimeoutTime;
        uint256 finishTime;
        uint256 failTime;
        uint256 timeoutTime;
        bool exist;
    }

    struct AddFileTaskProgress {
        uint256 time;
        uint256 lastSize;
        uint256 currentSize;
        uint256 size;
        bool exist;
    }

    function newTask(
        address owner,
        Action action,
        string calldata cid,
        uint256 size,
        address node,
        uint256 createTime
    ) external returns (uint256);
    function exist(uint256 tid) external view returns (bool);

    function getTaskItem(uint256 tid) external view returns (TaskItem memory);
    function getAction(uint256 tid) external view returns (Action);

    function getStatus(uint256 tid) external view returns (Status);
    function getCreateTime(uint256 tid) external view returns (uint256);
    function getStatusAndTime(uint256 tid) external view returns (Status, uint256);
    function getStatusInfo(uint256 tid) external view returns (StatusInfo memory);
    function setStatusAndTime(uint256 tid, Status status, uint256 time) external;

    function getAddFileTaskProgress(uint256 tid) external view returns (AddFileTaskProgress memory);
    function setAddFileTaskProgress(uint256 tid, uint256 time, uint256 size) external;
}
