pragma solidity ^0.5.17;

interface ITaskStorage {
    enum Status {
        Created,
        AcceptTimeout,
        Accepted,
        Timeout,
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
        uint256 createdBlock;
        uint256 AcceptTimeoutBlock;
        uint256 acceptedBlock;
        uint256 timeoutBlock;
        uint256 FinishedBlock;
        bool exist;
    }

    function currentTid() public view returns(uint256);
    function newTask(string calldata cid, string calldata pid, uint256 size, Action action, uint256 block) external returns(uint256);
    function exist(uint256 tid) external view returns (bool);
    function cid(uint256 tid) external returns(string memory);
    function pid(uint256 tid) external returns(string memory);
    function status(uint256 tid) external returns(Status);
    function setStatus(uint256 tid, Status status) external;
    function setAcceptBlock(uint256 tid, uint256 block) external;
    function setEndBlock(uint256 tid, uint256 block) external;
}
