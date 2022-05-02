pragma solidity ^0.5.2;
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

    struct TaskState {
        Status status;
        uint256 createBlockNumber;
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
        uint256 lastPercentage;
        uint256 currentPercentage;
        bool exist;
    }

    function exist(uint256 tid) external view returns (bool);
    function getCurrentTid() external view returns (uint256);
    function getNodeMaxTid(address addr) external view returns (uint256);
    function isOver(uint256 tid) external view returns (bool);

    function newTask(
        address owner,
        Action action,
        string calldata cid,
        uint256 size,
        address node
    ) external returns (uint256);

    function getTask(uint256 tid) external view returns (address, Action, address, uint256, string memory);
    function getOwner(uint256 tid) external view returns (address);
    function getAction(uint256 tid) external view returns (Action);
    function getNode(uint256 tid) external view returns (address);
    function getSize(uint256 tid) external view returns (uint256);
    function getCid(uint256 tid) external view returns (string memory);

    function getTaskState(uint256 tid) external view returns (Status, uint256, uint256, uint256, uint256, uint256, uint256, uint256);
    function getStatus(uint256 tid) external view returns (Status);
    function getCreateBlockNumber(uint256 tid) external view returns (uint256);
    function getCreateTime(uint256 tid) external view returns (uint256);
    function getAcceptTime(uint256 tid) external view returns (uint256);
    function getAcceptTimeoutTime(uint256 tid) external view returns (uint256);
    function getFinishTime(uint256 tid) external view returns (uint256);
    function getFailTime(uint256 tid) external view returns (uint256);
    function getTimeoutTime(uint256 tid) external view returns (uint256);

    function getStatusAndTime(uint256 tid) external view returns (Status, uint256);
    function setStatusAndTime(uint256 tid, Status status, uint256 time) external;

    function getAddFileTaskProgress(uint256 tid) external view returns (uint256, uint256, uint256, uint256, uint256, uint256);
    function setAddFileTaskProgressBySize(uint256 tid, uint256 time, uint256 size) external;
    function setAddFileTaskProgressByPercentage(uint256 tid, uint256 time, uint256 percentage) external;
}
