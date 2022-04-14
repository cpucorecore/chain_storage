pragma solidity ^0.5.17;

interface ITaskStorage {
    enum Status {
        Created,
        Accepted,
        Failed,
        Finished
    }

    enum Action {
        Add,
        Delete
    }

    struct TaskItem {
        string cid;
        string pid;
        uint256 size;
        Action action;
        Status status;
        uint256 retryCount;
        bool exist;
    }

    function currentTid() external view returns(uint256);
    function newTask(string calldata cid, string calldata pid, uint256 size) external returns(uint256);
    function cid(uint256 tid) external returns(string memory);
    function pid(uint256 tid) external returns(string memory);
    function status(uint256 tid) external returns(Status);
    function updateStatus(uint256 tid, Status status) external;
}
