pragma solidity ^0.5.2;
pragma experimental ABIEncoderV2;

import "../lib/Paging.sol";

interface IHistory {

    enum ActionType {
        Add,
        Delete
    }

    struct UserAction {
        uint256 timestamp;
        address addr;
        ActionType actionType;
        bytes32 cidHash;
    }

    struct NodeAction {
        uint256 timestamp;
        address addr;
        uint256 tid;
        ActionType actionType;
        bytes32 cidHash;
    }

    enum MonitorActionType {
        AcceptTimeout,
        Timeout
    }

    struct MonitorAction {
        uint256 timestamp;
        address addr;
        uint256 tid;
        MonitorActionType actionType;
        bytes32 cidHash;
    }

    function addUserAction(address addr, ActionType actionType, bytes32 cidHash) external;
    function getUserHistoryNumber() external view returns (uint256);
    function getUserHistory(uint256 index) external view returns (UserAction memory);
    function getUserHistoryIndexesByUser(address addr, uint256 pageSize, uint256 pageNumber) external view returns (uint256[] memory, Paging.Page memory);
    function getUserHistoryIndexesByCidHash(bytes32 cidHash, uint256 pageSize, uint256 pageNumber) external view returns (uint256[] memory, Paging.Page memory);
    function getUserHistoryIndexesByUserAndCidHash(address addr, bytes32 cidHash, uint256 pageSize, uint256 pageNumber) external view returns (uint256[] memory, Paging.Page memory);

    function addNodeAction(address addr, uint256 tid, ActionType actionType, bytes32 cidHash) external;
    function getNodeHistoryNumber() external view returns (uint256);
    function getNodeHistory(uint256 index) external view returns (NodeAction memory);
    function getNodeHistoryIndexesByNode(address addr, uint256 pageSize, uint256 pageNumber) external view returns (uint256[] memory, Paging.Page memory);
    function getNodeHistoryIndexesByCidHash(bytes32 cidHash, uint256 pageSize, uint256 pageNumber) external view returns (uint256[] memory, Paging.Page memory);
    function getNodeHistoryIndexesByNodeAndCidHash(address addr, bytes32 cidHash, uint256 pageSize, uint256 pageNumber) external view returns (uint256[] memory, Paging.Page memory);

    function addMonitorAction(address addr, uint256 tid, MonitorActionType actionType, bytes32 cidHash) external;
    function getMonitorHistoryNumber() external view returns (uint256);
    function getMonitorHistory(uint256 index) external view returns (MonitorAction memory);
    function getMonitorHistoryIndexesByMonitor(address addr, uint256 pageSize, uint256 pageNumber) external view returns (uint256[] memory, Paging.Page memory);
    function getMonitorHistoryIndexesByCidHash(bytes32 cidHash, uint256 pageSize, uint256 pageNumber) external view returns (uint256[] memory, Paging.Page memory);
    function getMonitorHistoryIndexesByMonitorAndCidHash(address addr, bytes32 cidHash, uint256 pageSize, uint256 pageNumber) external view returns (uint256[] memory, Paging.Page memory);
}
