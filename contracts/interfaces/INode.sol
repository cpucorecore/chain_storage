pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import "../lib/Paging.sol";

interface INode {
    function register(address addr, uint256 space, string calldata ext) external;
    function deRegister(address addr) external;

    function getExt(address addr) external view returns (string memory);
    function setExt(address addr, string calldata ext) external;

    function online(address addr) external;
    function maintain(address addr) external;

    function addFile(string calldata cid, uint256 size, uint256 duration) external;

    function getAllNodeAddresses(uint256 pageSize, uint256 pageNumber) external view returns (address[] memory, Paging.Page memory);
    function getNodeCids(address addr, uint256 pageSize, uint256 pageNumber) external view returns (string[] memory, Paging.Page memory);

    function taskAddFileFinished(uint256 tid, bool skip) external; // for node
    function taskAddFileFailed(uint256 tid) external; // for node
    function taskDeleteFileFinished(uint256 tid) external; // for node

    function taskAcceptTimeout(uint256 tid) external; // for monitor
    function taskTimeout(uint256 tid) external; // for monitor
}
