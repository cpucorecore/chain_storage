pragma solidity ^0.5.17;
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
    function getUserHistory(uint256 pageSize, uint256 pageNumber) external view returns(UserAction[] memory, Paging.Page memory);
    function getUserHistoryByUser(address addr, uint256 pageSize, uint256 pageNumber) external view returns(UserAction[] memory, Paging.Page memory);
    function getUserHistoryByCidHash(bytes32 cidHash, uint256 pageSize, uint256 pageNumber) external view returns(UserAction[] memory, Paging.Page memory);
    function getUserHistoryByUserAndCidHash(address addr, bytes32 cidHash, uint256 pageSize, uint256 pageNumber) external view returns(UserAction[] memory, Paging.Page memory);

    function addNodeAction(address addr, uint256 tid, ActionType actionType, bytes32 cidHash) external;
    function getNodeHistory(uint256 pageSize, uint256 pageNumber) external view returns(NodeAction[] memory, Paging.Page memory);
    function getNodeHistoryByNode(address addr, uint256 pageSize, uint256 pageNumber) external view returns(NodeAction[] memory, Paging.Page memory);
    function getNodeHistoryByCidHash(bytes32 cidHash, uint256 pageSize, uint256 pageNumber) external view returns(NodeAction[] memory, Paging.Page memory);
    function getNodeHistoryByNodeAndCidHash(address addr, bytes32 cidHash, uint256 pageSize, uint256 pageNumber) external view returns(NodeAction[] memory, Paging.Page memory);

    function addMonitorAction(address addr, uint256 tid, MonitorActionType actionType, bytes32 cidHash) external;
    function getMonitorHistory(uint256 pageSize, uint256 pageNumber) external view returns(MonitorAction[] memory, Paging.Page memory);
    function getMonitorHistoryByMonitor(address addr, uint256 pageSize, uint256 pageNumber) external view returns(MonitorAction[] memory, Paging.Page memory);
    function getMonitorHistoryByCidHash(bytes32 cidHash, uint256 pageSize, uint256 pageNumber) external view returns(MonitorAction[] memory, Paging.Page memory);
    function getMonitorHistoryByMonitorAndCidHash(address addr, bytes32 cidHash, uint256 pageSize, uint256 pageNumber) external view returns(MonitorAction[] memory, Paging.Page memory);
}
