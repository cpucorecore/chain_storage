pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import "../../lib/SafeMath.sol";
import "../../lib/Paging.sol";

interface INodeStorage {
    using SafeMath for uint256;

    enum Status {
        Registered,
        Online,
        Maintain,
        Offline,
        DeRegistered
    }

    struct StatusInfo {
        Status status;
        uint256 timestamp;
    }

    struct ServiceInfo {
        uint256 totalTaskAddAcceptTimeoutCount;
        uint256 totalTaskAddTimeoutCount;
        uint256 totalTaskDeleteAcceptTimeoutCount;
        uint256 totalTaskDeleteTimeoutCount;
        uint256 taskAddAcceptTimeoutCount;
        uint256 taskAddTimeoutCount;
        uint256 taskDeleteAcceptTimeoutCount;
        uint256 taskDeleteTimeoutCount;

        uint256 maintainCount;
        uint256 offlineCount;

        uint256 servingDuration;
        uint256 registerAt;
        uint256 onlineAt;
    }

    struct StorageInfo {
        uint256 used;
        uint256 space;
    }

    struct BlockInfo {
        uint256 currentBlock;
        uint256 targetBlock;
    }

    struct NodeItem {
        string pid;
        Status status;
        ServiceInfo serviceInfo;
        StorageInfo storageInfo;
        uint256 starve;
        BlockInfo blockInfo;
        string ext;
        uint256 score;
        bool exist;
    }

    function newNode(address addr, string calldata pid, uint256 space, string calldata ext) external;
    function deleteNode(address addr) external;
    function exist(address addr) external returns (bool);
    function node(address addr) external returns (NodeItem memory);

    function setSpace(address addr, uint256 space) external;
    function setUsed(address addr, uint256 space) external;

    function status(address addr) external view returns (Status);
    function setStatus(address addr, Status status) external;

    function taskAddAcceptTimeoutCount(address addr) external view returns (uint256);
    function taskAddTimeoutCount(address addr) external view returns (uint256);
    function taskDeleteAcceptTimeoutCount(address addr) external view returns (uint256);
    function taskDeleteTimeoutCount(address addr) external view returns (uint256);
    function upTaskAddAcceptTimeoutCount(address addr) external;
    function upTaskAddTimeoutCount(address addr) external;
    function upTaskDeleteAcceptTimeoutCount(address addr) external;
    function upTaskDeleteTimeoutCount(address addr) external;
    function resetTaskAddAcceptTimeoutCount(address addr) external;
    function resetTaskAddTimeoutCount(address addr) external;
    function resetTaskDeleteAcceptTimeoutCount(address addr) external;
    function resetTaskDeleteTimeoutCount(address addr) external;
    function totalTaskTimeoutCount(address addr) external view returns (uint256);

    function maintainCount(address addr) external view returns (uint256);
    function upMaintainCount(address addr) external;
    function offlineCount(address addr) external view returns (uint256);
    function upOfflineCount(address addr) external;

    function starve(address addr) external view returns (uint256);
    function setStarve(address addr, uint256 starve) external;

    function blockInfo(address addr) external view returns (BlockInfo memory);
    function setCurrentBlock(address addr, uint256 block) external;
    function setTargetBlock(address addr, uint256 block) external;

    function ext(address addr) external view returns (string memory);
    function setExt(address addr, string calldata ext) external;

    function storageInfo(address addr) external view returns (StorageInfo memory);
    function serviceInfo(address addr) external view returns (ServiceInfo memory);
    function freeSpace(address addr) external view returns (uint256);

    function pid(address addr) external view returns (string memory);
    function nodeAddresses(uint256 pageSize, uint256 pageNumber) external view returns (address[] memory, Paging.Page memory);
    function onlineNodeAddresses(uint256 pageSize, uint256 pageNumber) external view returns (address[] memory, Paging.Page memory);
    function cids(address addr, uint256 pageSize, uint256 pageNumber) external view returns (string[] memory, Paging.Page memory);
}
