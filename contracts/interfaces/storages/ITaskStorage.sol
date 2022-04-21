pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

interface ITaskStorage {
    enum Status {
        Created,
        AcceptTimeout,
        Accepted,
        Timeout,
        Finished,
        Failed
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

    struct TaskStatus {
        Status status;
        uint256 createBlock;
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
        uint256 lastProgress;
        uint256 progress;
        bool exist;
    }

    function newTask(
        address owner,
        Action action,
        string calldata cid,
        uint256 size,
        address node,
        uint256 createBlock,
        uint256 createTime
    ) external returns (uint256);
    function exist(uint256 tid) external view returns (bool);

    function getTaskItem(uint256 tid) external view returns (TaskItem memory);
    function getTaskStatus(uint256 tid) external view returns (TaskStatus memory);
    function getAddFileTaskProgress(uint256 tid) external view returns (AddFileTaskProgress memory);
}
