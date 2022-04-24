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

    struct ServiceInfo {
        uint256 maintainCount;
        uint256 offlineCount;
        uint256 taskFinishCount;
        uint256 taskFailCount;
        uint256 taskAcceptTimeoutCount;
        uint256 taskTimeoutCount;
    }

    struct StorageInfo {
        uint256 total;
        uint256 used;
    }

    struct TasksProgress {
        uint256 currentTime;
        uint256 targetTime;
    }

    struct NodeItem {
        Status status;
        ServiceInfo serviceInfo;
        StorageInfo storageInfo;
        TasksProgress tasksProgress;
        string ext;
        bool exist;
    }

    function newNode(address addr, uint256 totalSpace, string calldata ext) external;
    function deleteNode(address addr) external;
    function exist(address addr) external view returns (bool);
    function getNode(address addr) external view returns (NodeItem memory);

    function getServiceInfo(address addr) external view returns (ServiceInfo memory);
    function getStorageInfo(address addr) external view returns (StorageInfo memory);
    function getTasksProgress(address addr) external view returns (TasksProgress memory);

    function getStatus(address addr) external view returns (Status);
    function setStatus(address addr, Status status) external;

    function getMaintainCount(address addr) external view returns (uint256);
    function setMaintainCount(address addr, uint256 value) external;

    function getOfflineCount(address addr) external view returns (uint256);
    function setOfflineCount(address addr, uint256 value) external;

    function getTaskFinishCount(address addr) external view returns (uint256);
    function setTaskFinishCount(address addr, uint256 value) external;

    function getTaskFailCount(address addr) external view returns (uint256);
    function setTaskFailCount(address addr, uint256 value) external;

    function getTaskAcceptTimeoutCount(address addr) external view returns (uint256);
    function setTaskAcceptTimeoutCount(address addr, uint256 value) external;

    function getTaskTimeoutCount(address addr) external view returns (uint256);
    function setTaskTimeoutCount(address addr, uint256 value) external;

    function getStorageFree(address addr) external view returns (uint256);
    function getStorageTotal(address addr) external view returns (uint256);
    function setStorageTotal(address addr, uint256 value) external;

    function getStorageUsed(address addr) external view returns (uint256);
    function setStorageUsed(address addr, uint256 value) external;

    function getTasksProgressCurrentTime(address addr) external view returns (uint256);
    function setTasksProgressCurrentTime(address addr, uint256 value) external;
    function getTasksProgressTargetTime(address addr) external view returns (uint256);
    function getTasksProgressTargetTime(address addr, uint256 value) external;

    function getExt(address addr) external view returns (string memory);
    function setExt(address addr, string calldata ext) external;

    function getAllNodeAddresses(uint256 pageSize, uint256 pageNumber) external view returns (address[] memory, Paging.Page memory);
    function getAllOnlineNodeAddresses(uint256 pageSize, uint256 pageNumber) external view returns (address[] memory, Paging.Page memory);
    function getNodeCids(address addr, uint256 pageSize, uint256 pageNumber) external view returns (string[] memory, Paging.Page memory);

    function getAddFileFailedCount(string calldata cid) external view returns (uint256);
    function setAddFileFailedCount(string calldata cid, uint256 count) external;
}
