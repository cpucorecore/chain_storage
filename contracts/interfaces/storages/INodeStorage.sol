pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import "../../lib/SafeMath.sol";

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
        uint256 registeredAt;
        uint256 onlineAt;
        uint256 maintainAt;
        uint256 offlineAt;
    }

    struct StorageInfo {
        uint256 storageSpace;
        uint256 storageUsed;
    }

    struct NodeInfo {
        StatusInfo statusInfo;
        ServiceInfo serviceInfo;
        StorageInfo storageInfo;
        uint starve;
        address chainAccount;
        bool exist;
    }

    function newNode(string calldata pid, address chainAccount, uint256 storageSpace) external;
    function deleteNode(string calldata pid) external;
    function exist(string calldata pid) external returns(bool);
    function pids() external view returns(string[] memory);
    function updateStorageSpace(string calldata pid, uint256 storageSpace) external;
    function useStorageSpace(string calldata pid, uint256 spaceUsed) external;
    function online(string calldata pid) external;
    function offline(string calldata pid) external;
    function maintain(string calldata pid) external;
    function starve(string calldata pid, uint256 value) external;
    function starve(string calldata pid) external view returns(uint256);
    function status(string calldata pid) external returns(Status);
    function storageInfo(string calldata pid) external returns(StorageInfo memory);
    function serviceInfo(string calldata pid) external returns(ServiceInfo memory);
    function maintainCount(string calldata pid) external returns(uint256);
    function offlineCount(string calldata pid) external returns(uint256);

    function chainAccount(string calldata pid) external view returns(address);
}
