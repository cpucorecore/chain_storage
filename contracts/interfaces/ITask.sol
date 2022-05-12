pragma solidity ^0.5.2;

interface ITask {
    function issueTask(uint8, address owner, string calldata cid, address node, uint256 size) external returns (uint256);
    function acceptTask(address node, uint256 tid) external; // for storage server
    function finishTask(uint256 tid) external; // for Node()
    function failTask(uint256 tid) external; // for Node()
    function acceptTaskTimeout(uint256 tid) external; // for Monitor()-->Node()
    function taskTimeout(uint256 tid) external; // for Monitor()-->Node()
    function reportAddFileProgressBySize(address addr, uint256 tid, uint256 size) external; // for storage server
    function reportAddFileProgressByPercentage(address addr, uint256 tid, uint256 percentage) external; // for storage server
}
