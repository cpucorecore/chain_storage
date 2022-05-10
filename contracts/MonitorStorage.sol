pragma solidity ^0.5.2;
pragma experimental ABIEncoderV2;

import "./storages/ExternalStorage.sol";
import "./interfaces/storages/IMonitorStorage.sol";
import "./lib/EnumerableSet.sol";
import "./lib/Paging.sol";

contract MonitorStorage is ExternalStorage, IMonitorStorage {
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(address=>MonitorItem) monitors;
    EnumerableSet.AddressSet monitorAddrs;
    EnumerableSet.AddressSet onlineMonitorAddrs;

    mapping(address=>uint256) monitor2rid; // rid=0: no report;
    mapping(address=>Report[]) monitor2reports;

    constructor(address _manager) public ExternalStorage(_manager) {}

    function newMonitor(address addr, string calldata ext) external onlyManager(managerName) {
        monitors[addr] = MonitorItem(Status.Registered, 0, 0, ext, true);
        monitorAddrs.add(addr);
    }

    function deleteMonitor(address addr) external onlyManager(managerName) {
        delete monitors[addr];
        monitorAddrs.remove(addr);
    }

    function exist(address addr) external view returns (bool) {
        return monitors[addr].exist;
    }

    function getMonitor(address addr) external view returns (Status, uint256, uint256, string memory) {
        MonitorItem storage monitor = monitors[addr];
        return (monitor.status, monitor.firstOnlineTid, monitor.currentTid, monitor.ext);
    }

    function getCurrentTid(address addr) external view returns (uint256) {
        return monitors[addr].currentTid;
    }

    function setCurrentTid(address addr, uint256 tid) external onlyManager(managerName) {
        monitors[addr].currentTid = tid;
    }

    function getFirstOnlineTid(address addr) external view returns (uint256) {
        return monitors[addr].firstOnlineTid;
    }

    function setFirstOnlineTid(address addr, uint256 tid) external onlyManager(managerName) {
        monitors[addr].firstOnlineTid = tid;
    }

    function getStatus(address addr) external view returns (Status) {
        return monitors[addr].status;
    }

    function setStatus(address addr, Status status) external onlyManager(managerName) {
        monitors[addr].status = status;
    }

    function addOnlineMonitor(address addr) external onlyManager(managerName) {
        onlineMonitorAddrs.add(addr);
    }

    function deleteOnlineMonitor(address addr) external onlyManager(managerName) {
        onlineMonitorAddrs.remove(addr);
    }

    function getAllMonitorAddresses(uint256 pageSize, uint256 pageNumber) external view returns (address[] memory, bool) {
        Paging.Page memory page = Paging.getPage(monitorAddrs.length(), pageSize, pageNumber);
        uint256 start = page.pageNumber.sub(1).mul(page.pageSize);
        address[] memory result = new address[](page.pageRecords);
        for(uint256 i=0; i<page.pageRecords; i++) {
            result[i] = monitorAddrs.at(start+i);
        }
        return (result, page.pageNumber == page.totalPages);
    }

    function getAllOnlineMonitorAddresses(uint256 pageSize, uint256 pageNumber) external view returns (address[] memory, bool) {
        Paging.Page memory page = Paging.getPage(onlineMonitorAddrs.length(), pageSize, pageNumber);
        uint256 start = page.pageNumber.sub(1).mul(page.pageSize);
        address[] memory result = new address[](page.pageRecords);
        for(uint256 i=0; i<page.pageRecords; i++) {
            result[i] = onlineMonitorAddrs.at(start+i);
        }
        return (result, page.pageNumber == page.totalPages);
    }

    function addReport(address addr, uint256 tid, ReportType reportType, uint256 timestamp) external onlyManager(managerName) {
        uint256 index = monitor2reports[addr].push(Report(tid, reportType, timestamp));
        monitor2rid[addr] = index;
    }

    function getReportNumber(address addr) external view returns (uint256) {
        return monitor2rid[addr];
    }

    function getReport(address addr, uint256 index) external view returns (uint256, ReportType, uint256) {
        Report storage report = monitor2reports[addr][index];
        return (report.tid, report.reportType, report.timestamp);
    }
}
