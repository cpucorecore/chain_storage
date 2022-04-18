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
    
    struct MonitorItem {
        Status status;
        uint256 currentTid;
        string ext;
        bool exist;
    }

    struct Report {
        uint256 tid;
        uint256 timestamp;
    }

    function newMonitor(address addr, string calldata ext) external;
    function deleteMonitor(address addr) external;
    function exist(address addr) external view returns (bool);
    function monitor(address addr) external view returns (MonitorItem memory);
    function currentTid(address addr) external view returns (uint256);
    function setCurrentTid(address addr, uint256 tid) external;

    function status(address addr) external view returns (Status);
    function setStatus(address addr, Status status) external;

    function addReport(address addr, uint256 tid, uint256 timestamp) external;

    function monitorAddresses(uint256 pageSize, uint256 pageNumber) external view returns (address[] memory, Paging.Page memory);
    function onlineMonitorAddresses(uint256 pageSize, uint256 pageNumber) external view returns (address[] memory, Paging.Page memory);
    function reports(address addr, uint256 pageSize, uint256 pageNumber) external view returns (Report[] memory, Paging.Page memory);
}
