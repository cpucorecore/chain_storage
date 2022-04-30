pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import "../../lib/SafeMath.sol";
import "../../lib/Paging.sol";

interface INodeStorage {
    using SafeMath for uint256;

    enum Status {
        Default,
        Registered,
        Online,
        Maintain,
        Offline,
        DeRegistered
    }

    struct ServiceInfo {
        uint256 maintainCount;
        uint256 offlineCount;
        uint256 taskAddFileFinishCount;
        uint256 taskAddFileFailCount;
        uint256 taskDeleteFileFinishCount;
        uint256 taskAcceptTimeoutCount;
        uint256 taskTimeoutCount;
    }

    struct StorageSpaceInfo {
        uint256 total;
        uint256 used;
    }

    struct NodeItem {
        Status status;
        ServiceInfo serviceInfo;
        StorageSpaceInfo storageInfo;
        uint256 maxFinishedTid;
        string ext;
        bool exist;
    }

    function exist(address addr) external view returns (bool);
    function newNode(address addr, uint256 totalSpace, string calldata ext) external;
    function deleteNode(address addr) external;
    function getNode(address addr) external view returns (NodeItem memory);

    function isNodeOnline(address addr) external view returns (bool);
    function addOnlineNode(address addr) external;
    function deleteOnlineNode(address addr) external;

    function getServiceInfo(address addr) external view returns (ServiceInfo memory);
    function getStorageSpaceInfo(address addr) external view returns (StorageSpaceInfo memory);

    function getMaxFinishedTid(address addr) external view returns (uint256);
    function setMaxFinishedTid(address addr, uint256 tid) external;

    function getStatus(address addr) external view returns (Status);
    function setStatus(address addr, Status status) external;

    function getMaintainCount(address addr) external view returns (uint256);
    function setMaintainCount(address addr, uint256 value) external;

    function getOfflineCount(address addr) external view returns (uint256);
    function setOfflineCount(address addr, uint256 value) external;

    function getTaskAddFileFinishCount(address addr) external view returns (uint256);
    function setTaskAddFileFinishCount(address addr, uint256 value) external;

    function getTaskAddFileFailCount(address addr) external view returns (uint256);
    function setTaskAddFileFailCount(address addr, uint256 value) external;

    function getTaskDeleteFileFinishCount(address addr) external view returns (uint256);
    function setTaskDeleteFileFinishCount(address addr, uint256 value) external;

    function getTaskAcceptTimeoutCount(address addr) external view returns (uint256);
    function setTaskAcceptTimeoutCount(address addr, uint256 value) external;

    function getTaskTimeoutCount(address addr) external view returns (uint256);
    function setTaskTimeoutCount(address addr, uint256 value) external;

    function getStorageFree(address addr) external view returns (uint256);
    function getStorageTotal(address addr) external view returns (uint256);
    function setStorageTotal(address addr, uint256 value) external;

    function getStorageUsed(address addr) external view returns (uint256);
    function setStorageUsed(address addr, uint256 value) external;

    function getExt(address addr) external view returns (string memory);
    function setExt(address addr, string calldata ext) external;

    function getAllNodeAddresses() external view returns (address[] memory);
    function getAllNodeAddresses(uint256 pageSize, uint256 pageNumber) external view returns (address[] memory, Paging.Page memory);

    function getAllOnlineNodeAddresses() external view returns (address[] memory);
    function getAllOnlineNodeAddresses(uint256 pageSize, uint256 pageNumber) external view returns (address[] memory, Paging.Page memory);

    function cidExist(address addr, string calldata cid) external view returns (bool);
    function addNodeCid(address addr, string calldata cid) external;
    function removeNodeCid(address addr, string calldata cid) external;
    function getNodeCidsNumber(address addr) external view returns (uint256);
    function getNodeCids(address addr) external view returns (string[] memory);
    function getNodeCids(address addr, uint256 pageSize, uint256 pageNumber) external view returns (string[] memory, Paging.Page memory);

    function getAddFileFailedCount(string calldata cid) external view returns (uint256);
    function setAddFileFailedCount(string calldata cid, uint256 count) external;

    function getTotalNodeNumber() external view returns (uint256);
    function getTotalOnlineNodeNumber() external view returns (uint256);
}
