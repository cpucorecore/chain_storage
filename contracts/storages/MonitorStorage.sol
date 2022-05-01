pragma solidity ^0.5.2;
pragma experimental ABIEncoderV2;

import "../interfaces/storages/IMonitorStorage.sol";
import "../lib/EnumerableSet.sol";
import "./ExternalStorage.sol";
import "../lib/Paging.sol";

contract MonitorStorage is ExternalStorage, IMonitorStorage {
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(address=>MonitorItem) monitors;
    EnumerableSet.AddressSet monitorAddrs;
    EnumerableSet.AddressSet onlineMonitorAddrs;

    mapping(address=>uint256) monitor2rid; // rid=0: no report;
    mapping(address=>Report[]) monitor2reports;

    constructor(address _manager) public ExternalStorage(_manager) {}

    function newMonitor(address addr, string calldata ext) external {
        monitors[addr] = MonitorItem(Status.Registered, 0, 0, ext, true);
        monitorAddrs.add(addr);
    }

    function deleteMonitor(address addr) external {
        delete monitors[addr];
        monitorAddrs.remove(addr);
    }

    function exist(address addr) external view returns (bool) {
        return monitors[addr].exist;
    }

    function getMonitor(address addr) external view returns (MonitorItem memory) {
        return monitors[addr];
    }

    function getCurrentTid(address addr) external view returns (uint256) {
        return monitors[addr].currentTid;
    }

    function setCurrentTid(address addr, uint256 tid) external {
        monitors[addr].currentTid = tid;
    }

    function getFirstOnlineTid(address addr) external view returns (uint256) {
        return monitors[addr].firstOnlineTid;
    }

    function setFirstOnlineTid(address addr, uint256 tid) external {
        monitors[addr].firstOnlineTid = tid;
    }

    function getStatus(address addr) external view returns (Status) {
        return monitors[addr].status;
    }

    function setStatus(address addr, Status status) external {
        monitors[addr].status = status;
    }

    function addOnlineMonitor(address addr) external {
        onlineMonitorAddrs.add(addr);
    }

    function deleteOnlineMonitor(address addr) external {
        onlineMonitorAddrs.remove(addr);
    }

    function getAllMonitorAddresses(uint256 pageSize, uint256 pageNumber) external view returns (address[] memory, Paging.Page memory) {
        Paging.Page memory page = Paging.getPage(monitorAddrs.length(), pageSize, pageNumber);
        uint256 start = page.pageNumber.sub(1).mul(page.pageSize);
        address[] memory result = new address[](page.pageRecords);
        for(uint256 i=0; i<page.pageRecords; i++) {
            result[i] = monitorAddrs.at(start+i);
        }
        return (result, page);
    }

    function getAllOnlineMonitorAddresses(uint256 pageSize, uint256 pageNumber) external view returns (address[] memory, Paging.Page memory) {
        Paging.Page memory page = Paging.getPage(onlineMonitorAddrs.length(), pageSize, pageNumber);
        uint256 start = page.pageNumber.sub(1).mul(page.pageSize);
        address[] memory result = new address[](page.pageRecords);
        for(uint256 i=0; i<page.pageRecords; i++) {
            result[i] = onlineMonitorAddrs.at(start+i);
        }
        return (result, page);
    }

    function addReport(address addr, uint256 tid, ReportType reportType, uint256 timestamp) external {
        monitor2rid[addr] = monitor2rid[addr].add(1);
        monitor2reports[addr].push(Report(tid, reportType, timestamp));
    }

    function getReports(address addr, uint256 pageSize, uint256 pageNumber) external view returns (Report[] memory, Paging.Page memory) {
        Paging.Page memory page = Paging.getPage(monitor2rid[addr], pageSize, pageNumber);
        uint256 start = page.pageNumber.sub(1).mul(page.pageSize);
        Report[] memory result = new Report[](page.pageRecords);
        for(uint256 i=0; i<page.pageRecords; i++) {
            result[i] = monitor2reports[addr][start+i];
        }
        return (result, page);
    }
}
