pragma solidity ^0.5.17;

interface ITask {
    function issueTaskAdd(string calldata cid, string calldata pid, uint256 size, uint256 duration) external returns(uint256);
    function issueTaskDelete(string calldata cid, string calldata pid, uint256 size) external returns(uint256);
    function finishTask(uint256 tid) external;
    function failTask(uint256 tid) external;
    function retryTask(uint256 tid) external;
}
