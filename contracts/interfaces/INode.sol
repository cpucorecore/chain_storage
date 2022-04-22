pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import "../lib/Paging.sol";

interface INode {
    function register(address addr, uint256 space, string calldata ext) external;
    function exist(address addr) external view returns (bool);

    function getExt(address addr) external view returns (string memory);
    function setExt(address addr, string calldata ext) external;

    function online(address addr) external;
    function maintain(address addr) external;

    function addFile(address owner, string calldata cid, uint256 size) external;

    function getAllNodeAddresses(uint256 pageSize, uint256 pageNumber) external view returns (address[] memory, Paging.Page memory);
    function getNodeCids(address addr, uint256 pageSize, uint256 pageNumber) external view returns (string[] memory, Paging.Page memory);

    function finishTask(uint256 tid) external;
    function failTask(uint256 tid) external;
    function taskAcceptTimeout(uint256 tid) external;
    function taskTimeout(uint256 tid) external;
}
