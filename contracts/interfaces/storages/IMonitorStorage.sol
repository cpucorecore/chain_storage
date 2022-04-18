pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import "../../lib/Paging.sol";

interface IMonitorStorage {
    enum Status {
        Registered,
        Online,
        Maintain,
        Offline,
        DeRegistered
    }
    
    struct MonitorItem {
        Status status;
        string ext;
        bool exist;
    }

    function newMonitor(address addr, string calldata ext) external;
    function deleteMonitor(address addr) external;
    function exist(address addr) external returns (bool);
    function Monitor(address addr) external returns (MonitorItem memory);

    function status(address addr) external view returns (Status);
    function setStatus(address addr, Status status) external;

    function monitorAddresses(uint256 pageSize, uint256 pageNumber) external view returns (address[] memory, Paging.Page memory);
    function onlineMonitorAddresses(uint256 pageSize, uint256 pageNumber) external view returns (address[] memory, Paging.Page memory);
}
