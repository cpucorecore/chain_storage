pragma solidity ^0.5.2;
pragma experimental ABIEncoderV2;

interface IHistory {
    struct UserAction {
        uint256 timestamp;
        address addr;
        uint8 actionType;
        bytes32 cidHash;
    }

    struct NodeAction {
        uint256 timestamp;
        address addr;
        uint256 tid;
        uint8 actionType;
        bytes32 cidHash;
    }

    struct MonitorAction {
        uint256 timestamp;
        address addr;
        uint256 tid;
        uint8 actionType;
        bytes32 cidHash;
    }

    function addUserAction(address addr, uint8 actionType, bytes32 cidHash) external;
    function getUserHistoryNumber() external view returns (uint256);
    function getUserHistory(uint256 index) external view returns (uint256, address, uint8, bytes32); // (timestamp, addr, actionType, cidHash)
    function getUserHistoryIndexesByUser(address addr, uint256 pageSize, uint256 pageNumber) external view returns (uint256[] memory, bool);
    function getUserHistoryIndexesByCidHash(bytes32 cidHash, uint256 pageSize, uint256 pageNumber) external view returns (uint256[] memory, bool);
    function getUserHistoryIndexesByUserAndCidHash(address addr, bytes32 cidHash, uint256 pageSize, uint256 pageNumber) external view returns (uint256[] memory, bool);

    function addNodeAction(address addr, uint256 tid, uint8 actionType, bytes32 cidHash) external;
    function getNodeHistoryNumber() external view returns (uint256);
    function getNodeHistory(uint256 index) external view returns (uint256, address, uint256, uint8, bytes32); // (timestamp, addr, tid, actionType, cidHash)
    function getNodeHistoryIndexesByNode(address addr, uint256 pageSize, uint256 pageNumber) external view returns (uint256[] memory, bool);
    function getNodeHistoryIndexesByCidHash(bytes32 cidHash, uint256 pageSize, uint256 pageNumber) external view returns (uint256[] memory, bool);
    function getNodeHistoryIndexesByNodeAndCidHash(address addr, bytes32 cidHash, uint256 pageSize, uint256 pageNumber) external view returns (uint256[] memory, bool);

    function addMonitorAction(address addr, uint256 tid, uint8 actionType, bytes32 cidHash) external;
    function getMonitorHistoryNumber() external view returns (uint256);
    function getMonitorHistory(uint256 index) external view returns (uint256, address, uint256, uint8, bytes32); // (timestamp, addr, tid, actionType, cidHash
    function getMonitorHistoryIndexesByMonitor(address addr, uint256 pageSize, uint256 pageNumber) external view returns (uint256[] memory, bool);
    function getMonitorHistoryIndexesByCidHash(bytes32 cidHash, uint256 pageSize, uint256 pageNumber) external view returns (uint256[] memory, bool);
    function getMonitorHistoryIndexesByMonitorAndCidHash(address addr, bytes32 cidHash, uint256 pageSize, uint256 pageNumber) external view returns (uint256[] memory, bool);
}
