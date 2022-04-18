pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import "../interfaces/storages/IMonitorStorage.sol";
import "../lib/EnumerableSet.sol";
import "./ExternalStorage.sol";
import "../lib/Paging.sol";

contract MonitorStorage is ExternalStorage, IMonitorStorage {
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(address=> MonitorItem) monitors;
    EnumerableSet.AddressSet monitorAddrs;
    EnumerableSet.AddressSet onlineMonitorAddrs;

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
}
