pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import "../../lib/Paging.sol";

interface IMonitorStorage {
    enum Status {
        Registered,
        Online,
        Maintain,
        DeRegistered
    }

    enum ReportType {
        AcceptTimeout,
        Timeout
    }
    
    struct MonitorItem {
        Status status;
        uint256 firstOnlineTid;
        uint256 currentTid;
        string ext;
        bool exist;
    }

    struct Report {
        uint256 tid;
        ReportType reportType;
        uint256 timestamp;
    }

    function newMonitor(address addr, string calldata ext) external;
    function deleteMonitor(address addr) external;
    function exist(address addr) external view returns (bool);
    function getMonitor(address addr) external view returns (MonitorItem memory);

    function getCurrentTid(address addr) external view returns (uint256);
    function setCurrentTid(address addr, uint256 tid) external;

    function getFirstOnlineTid(address addr) external view returns (uint256);
    function setFirstOnlineTid(address addr, uint256 tid) external;

    function getStatus(address addr) external view returns (Status);
    function setStatus(address addr, Status status) external;

    function addOnlineMonitor(address addr) external;
    function deleteOnlineMonitor(address addr) external;

    function getAllMonitorAddresses(uint256 pageSize, uint256 pageNumber) external view returns (address[] memory, Paging.Page memory);
    function getAllOnlineMonitorAddresses(uint256 pageSize, uint256 pageNumber) external view returns (address[] memory, Paging.Page memory);

    function addReport(address addr, uint256 tid, ReportType reportType, uint256 timestamp) external;
    function getReports(address addr, uint256 pageSize, uint256 pageNumber) external view returns (Report[] memory, Paging.Page memory);
}
