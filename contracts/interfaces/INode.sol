pragma solidity ^0.5.17;

import "../lib/Paging.sol";
pragma experimental ABIEncoderV2;

interface INode {
    function register(address addr, string calldata pid, uint256 space) external;
    function deRegister(address addr) external;

    function online(address addr) external;
    function offline(address addr) external;
    function maintain(address addr) external;

    function addFile(string calldata cid, uint256 size, uint256 duration) external;

    function pid(address addr) external view returns (string memory);
    function pids(uint256 pageSize, uint256 pageNumber) external view returns (string[] memory, Paging.Page memory);
    function cids(address addr, uint256 pageSize, uint256 pageNumber) external view returns (string[] memory, Paging.Page memory);

    function starve(address addr) external view returns (uint256);

    function taskFinished(uint256 tid) external;
    function taskFailed(uint256 tid) external;
}
