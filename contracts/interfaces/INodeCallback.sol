pragma solidity ^0.5.2;

interface INodeCallback {
    function finishTask(address addr, uint256 tid) external; // for node
    function failTask(address addr, uint256 tid) external; // for node
    function taskAcceptTimeout(address addr, uint256 tid) external; // for monitor
    function taskTimeout(address addr, uint256 tid) external; // for monitor
}
