pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import "../lib/Paging.sol";
import "./storages/INodeStorage.sol";

interface INode {
    function exist(address addr) external view returns (bool);
    function register(address addr, uint256 space, string calldata ext) external;
    function deRegister(address addr) external;

    function getExt(address addr) external view returns (string memory);
    function setExt(address addr, string calldata ext) external;

    function changeSpace(address addr, uint256 space) external;
    function getStorageSpaceInfo(address addr) external view returns (INodeStorage.StorageSpaceInfo memory);

    function online(address addr) external;
    function maintain(address addr) external;

    function getAllNodeAddresses() external view returns (address[] memory);
    function getAllNodeAddresses(uint256 pageSize, uint256 pageNumber) external view returns (address[] memory, Paging.Page memory);

    function getAllOnlineNodeAddresses() external view returns (address[] memory);
    function getAllOnlineNodeAddresses(uint256 pageSize, uint256 pageNumber) external view returns (address[] memory, Paging.Page memory);

    function addFile(address owner, string calldata cid, uint256 size) external;

    function finishTask(address addr, uint256 tid) external;
    function failTask(address addr, uint256 tid) external;

    function taskAcceptTimeout(uint256 tid) external; // for monitor
    function taskTimeout(uint256 tid) external; // for monitor

    function getNodeCids(address addr) external view returns (string[] memory);
    function getNodeCids(address addr, uint256 pageSize, uint256 pageNumber) external view returns (string[] memory, Paging.Page memory);

    function getTotalNodeNumber() external view returns (uint256);
    function getTotalOnlineNodeNumber() external view returns (uint256);
}
