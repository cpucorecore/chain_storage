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
        uint256 offlineCount;
        uint256 maintainCount;
        uint256 servingDuration;
        uint256 registerAt;
        uint256 onlineAt;
    }

    struct StorageInfo {
        uint256 used;
        uint256 space;
    }

    struct NodeItem {
        string pid;
        Status status;
        ServiceInfo serviceInfo;
        StorageInfo storageInfo;
        uint256 starve;
        uint256 block;
        bool exist;
    }

    function newNode(address addr, string calldata pid, uint256 space) external;
    function deleteNode(address addr) external;
    function exist(address addr) external returns (bool);
    function node(address addr) external returns (NodeItem memory);

    function setSpace(address addr, uint256 space) external;
    function setUsed(address addr, uint256 space) external;

    function status(address addr) external view returns (Status);
    function setStatus(address addr, Status status) external;
    function maintainCount(address addr) external view returns (uint256);
    function offlineCount(address addr) external view returns (uint256);

    function starve(address addr) external view returns (uint256);
    function setStarve(address addr, uint256 starve) external;

    function block(address addr) external view returns (uint256);
    function setBlock(address addr, uint256 block) external;

    function storageInfo(address addr) external view returns (StorageInfo memory);
    function serviceInfo(address addr) external view returns (ServiceInfo memory);

    function pid(address addr) external view returns (string memory);
    function nodeAddresses(uint256 pageSize, uint256 pageNumber) external view returns (address[] memory, Paging.Page memory);
    function onlineNodeAddresses(uint256 pageSize, uint256 pageNumber) external view returns (address[] memory, Paging.Page memory);
    function cids(address addr, uint256 pageSize, uint256 pageNumber) external view returns (string[] memory, Paging.Page memory);
}
