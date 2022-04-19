pragma solidity ^0.5.17;

interface ITask {
    function issueTaskAdd(string calldata cid, address node, uint256 size, uint256 duration) external;
    function issueTaskDelete(string calldata cid, address node, uint256 size) external;
    function acceptTask(uint256 tid) external;
    function finishTask(uint256 tid) external;
    function failTask(uint256 tid) external;
    function retryTask(uint256 tid) external;
}
