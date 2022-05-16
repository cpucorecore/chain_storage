pragma solidity ^0.5.2;

interface INodeTaskHandler {
    function finishTask(address addr, uint256 tid, uint256 size) external;
    function failTask(address addr, uint256 tid) external;
    function reportAcceptTaskTimeout(address addr, uint256 tid) external;
    function reportTaskTimeout(address addr, uint256 tid) external;
}
