pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import "../interfaces/storages/IMonitorStorage.sol";
import "../lib/EnumerableSet.sol";
import "./ExternalStorage.sol";
import "../lib/Paging.sol";

contract MonitorStorage is ExternalStorage, IMonitorStorage {
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;

    mapping(address=>MonitorItem) monitors;
    EnumerableSet.AddressSet monitorAddrs;
    EnumerableSet.AddressSet onlineMonitorAddrs;

    mapping(address=>uint256) monitor2reportCount;
    mapping(address=>Report[]) monitor2reports;

    constructor(address _manager) public ExternalStorage(_manager) {}

    function newMonitor(address addr, string calldata ext) external {
        monitors[addr] = MonitorItem(Status.Registered, ext, true);
        monitorAddrs.add(addr);
    }

    function deleteMonitor(address addr) external {
        delete monitors[addr];
        monitorAddrs.remove(addr);
    }

    function exist(address addr) external returns (bool) {
        return monitors[addr].exist;
    }

    function Monitor(address addr) external returns (MonitorItem memory) {
        return monitors[addr];
    }

    function status(address addr) external view returns (Status) {
        return monitors[addr].status;
    }

    function setStatus(address addr, Status status) external {
        monitors[addr].status = status;
        
        if(Status.Online == status) {
            onlineMonitorAddrs.add(addr);
        } else if(Status.Maintain == status) {
            onlineMonitorAddrs.remove(addr);
        } else if(Status.Offline == status) {
            onlineMonitorAddrs.remove(addr);
        } else if(Status.DeRegistered == status) {
            onlineMonitorAddrs.remove(addr);
        }
    }

    mapping(address=>EnumerableSet.UintSet) monitor2rids;
    mapping(address=>mapping(uint256=>Report)) monitorRid2report;
    function addReport(address addr, uint256 tid, uint256 timestamp) external {
        monitor2reportCount[addr] = monitor2reportCount[addr].add(1);
        monitor2reports[addr].push(Report(tid, timestamp));
    }

    function monitorAddresses(uint256 pageSize, uint256 pageNumber) external view returns (address[] memory, Paging.Page memory) {
        Paging.Page memory page = Paging.getPage(monitorAddrs.length(), pageSize, pageNumber);
        uint256 start = page.pageNumber.sub(1).mul(page.pageSize);
        address[] memory result = new address[](page.pageRecords);
        for(uint256 i=0; i<page.pageRecords; i++) {
            result[i] = monitorAddrs.at(start+i);
        }
        return (result, page);
    }

    function onlineMonitorAddresses(uint256 pageSize, uint256 pageNumber) external view returns (address[] memory, Paging.Page memory) {
        Paging.Page memory page = Paging.getPage(onlineMonitorAddrs.length(), pageSize, pageNumber);
        uint256 start = page.pageNumber.sub(1).mul(page.pageSize);
        address[] memory result = new address[](page.pageRecords);
        for(uint256 i=0; i<page.pageRecords; i++) {
            result[i] = onlineMonitorAddrs.at(start+i);
        }
        return (result, page);
    }

    function reports(address addr, uint256 pageSize, uint256 pageNumber) external view returns (Report[] memory, Paging.Page memory) {
        Paging.Page memory page = Paging.getPage(monitor2reportCount[addr], pageSize, pageNumber);
        uint256 start = page.pageNumber.sub(1).mul(page.pageSize);
        Report[] memory result = new Report[](page.pageRecords);
        for(uint256 i=0; i<page.pageRecords; i++) {
            result[i] = monitor2reports[addr][start+i];
        }
        return (result, page);
    }
}
