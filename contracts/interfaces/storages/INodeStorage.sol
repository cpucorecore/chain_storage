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
        uint256 continuousTimeoutCount;
        uint256 maintainCount;
        uint256 offlineCount;
        uint256 taskAddAcceptTimeoutCount;
        uint256 taskAddTimeoutCount;
        uint256 taskDeleteAcceptTimeoutCount;
        uint256 taskDeleteTimeoutCount;
    }

    struct Space {
        uint256 total;
        uint256 used;
    }

    struct TaskBlock {
        uint256 current;
        uint256 target;
    }

    struct NodeItem {
        Status status;
        ServiceInfo serviceInfo;
        Space space;
        TaskBlock taskBlock;
        string ext;
        bool exist;
    }

    function newNode(address addr, uint256 totalSpace, string calldata ext) external;
    function deleteNode(address addr) external;
    function exist(address addr) external view returns (bool);

    function getNode(address addr) external view returns (NodeItem memory);
    function getServiceInfo(address addr) external view returns (ServiceInfo memory);
    function getSpace(address addr) external view returns (Space memory);
    function getTaskBlock(address addr) external view returns (TaskBlock memory);

    function getStatus(address addr) external view returns (Status);
    function setStatus(address addr, Status status) external;

    function getContinuousTimeoutCount(address addr) external view returns (uint256);
    function setContinuousTimeoutCount(address addr, uint256 value) external;

    function getMaintainCount(address addr) external view returns (uint256);
    function setMaintainCount(address addr, uint256 value) external;

    function getOfflineCount(address addr) external view returns (uint256);
    function setOfflineCount(address addr, uint256 value) external;

    function getTaskAddAcceptTimeoutCount(address addr) external view returns (uint256);
    function setTaskAddAcceptTimeoutCount(address addr, uint256 value) external;

    function getTaskAddTimeoutCount(address addr) external view returns (uint256);
    function setTaskAddTimeoutCount(address addr, uint256 value) external;

    function getTaskDeleteAcceptTimeoutCount(address addr) external view returns (uint256);
    function setTaskDeleteAcceptTimeoutCount(address addr, uint256 value) external;

    function getTaskDeleteTimeoutCount(address addr) external view returns (uint256);
    function setTaskDeleteTimeoutCount(address addr, uint256 value) external;

    function getTotalSpace(address addr) external view returns (uint256);
    function setTotalSpace(address addr, uint256 value) external;

    function getUsedSpace(address addr) external view returns (uint256);
    function setUsedSpace(address addr, uint256 value) external;

    function getCurrentTaskBlock(address addr) external view returns (uint256);
    function setCurrentTaskBlock(address addr, uint256 value) external;

    function getTargetTaskBlock(address addr) external view returns (uint256);
    function setTargetTaskBlock(address addr, uint256 value) external;

    function getExt(address addr) external view returns (string memory);
    function setExt(address addr, string calldata ext) external;

    function getAllNodeAddresses(uint256 pageSize, uint256 pageNumber) external view returns (address[] memory, Paging.Page memory);
    function getAllOnlineNodeAddresses(uint256 pageSize, uint256 pageNumber) external view returns (address[] memory, Paging.Page memory);
    function getNodeCids(address addr, uint256 pageSize, uint256 pageNumber) external view returns (string[] memory, Paging.Page memory);
}
