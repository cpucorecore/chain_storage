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
        address node;
        uint256 size;
        Action action;
        Status status;
        uint256 createdBlock;
        uint256 acceptTimeoutBlock;
        uint256 acceptedBlock;
        uint256 timeoutBlock;
        uint256 FinishedBlock;
        bool exist;
    }

    function currentTid() external view returns(uint256);
    function newTask(string calldata cid, address node, uint256 size, Action action, uint256 block) external returns (uint256);
    function exist(uint256 tid) external view returns (bool);
    function cid(uint256 tid) external view returns (string memory);
    function node(uint256 tid) external view returns (address);
    function status(uint256 tid) external view returns (Status);
    function setStatus(uint256 tid, Status status) external;
    function acceptTimeoutBlock(uint256 tid) external view returns (uint256);
    function setAcceptTimeoutBlock(uint256 tid, uint256 block) external;
    function acceptedBlock(uint256 tid) external view returns (uint256);
    function setAcceptedBlock(uint256 tid, uint256 block) external;
    function timeoutBlock(uint256 tid) external view returns (uint256);
    function setTimeoutBlock(uint256 tid, uint256 block) external;
    function finishedBlock(uint256 tid) external view returns (uint256);
    function setFinishedBlock(uint256 tid, uint256 block) external;
    function blockInfo(uint256 tid) external view returns (uint256, uint256, uint256, uint256, uint256);
}
