pragma solidity ^0.5.2;

interface INodeFileHandler {
    function addFile(address owner, string calldata cid, uint256 size) external; // for file
    function finishTask(address addr, uint256 tid) external; // for node
    function failTask(address addr, uint256 tid) external; // for node
    function taskAcceptTimeout(address addr, uint256 tid) external; // for monitor
    function taskTimeout(address addr, uint256 tid) external; // for monitor
}
