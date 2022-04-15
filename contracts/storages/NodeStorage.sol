pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import "./ExternalStorage.sol";
import "../interfaces/storages/INodeStorage.sol";
import "../lib/EnumerableSet.sol";
import "../lib/Paging.sol";

contract NodeStorage is ExternalStorage, INodeStorage {
    using EnumerableSet for EnumerableSet.Bytes32Set;
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(address=> NodeItem) nodes;
    EnumerableSet.AddressSet nodeAddrs;

    mapping(address=>EnumerableSet.Bytes32Set) node2cidHashs;
    mapping(bytes32=>string) cidHash2cid;

    constructor(address _manager) public ExternalStorage(_manager) {}

    function newNode(address addr, string memory pid, uint256 space) public {
        nodes[addr] = NodeItem(pid,
            Status.Registered,
            ServiceInfo(0, 0, 0, now, 0),
            StorageInfo(0, space),
            0, true);

        EnumerableSet.Bytes32Set memory cidHashs;
        node2cidHashs[addr] = cidHashs;

        nodeAddrs.add(addr);
    }

    function deleteNode(address addr) public {
        delete nodes[addr];
        delete node2cidHashs[addr];
        nodeAddrs.remove(addr);
    }

    function exist(address addr) public returns (bool) {
        return nodes[addr].exist;
    }

    function setSpace(address addr, uint256 space) public {
        nodes[addr].storageInfo.space = space;
    }

    function setUsed(address addr, uint256 used) public {
        nodes[addr].storageInfo.used = used;
    }

    function status(address addr) public view returns (Status) {
        return nodes[addr].status;
    }

    function setStatus(address addr, Status status) public {
        nodes[addr].status = status;
    }

    function maintainCount(address addr) public view returns (uint256) {
        return nodes[addr].serviceInfo.maintainCount;
    }

    function offlineCount(address addr) public view returns (uint256) {
        return nodes[addr].serviceInfo.offlineCount;
    }

    function starve(address addr) public view returns (uint256) {
        return nodes[addr].starve;
    }

    function setStarve(address addr, uint256 starve) public {
        nodes[addr].starve = starve;
    }

    function storageInfo(address addr) public view returns (StorageInfo memory) {
        return nodes[addr].storageInfo;
    }

    function serviceInfo(address addr) public view returns (ServiceInfo memory) {
        return nodes[addr].serviceInfo;
    }

    function pid(address addr) public view returns (string memory) {
        return nodes[addr].pid;
    }

    function pids(uint256 pageSize, uint256 pageNumber) public view returns (string[] memory, Paging.Page memory) {
        Paging.Page memory page = Paging.getPage(nodeAddrs.length(), pageSize, pageNumber);

        uint256 start = page.pageNumber.sub(1).mul(page.pageSize);

        string[] memory result = new string[](page.pageRecords);
        for(uint256 i=0; i<page.pageRecords; i++) {
            result[i] = nodes[nodeAddrs.at(start+i)].pid;
        }

        return (result, page);
    }

    function cids(address addr, uint256 pageSize, uint256 pageNumber) public view returns (string[] memory, Paging.Page memory) {
        EnumerableSet.Bytes32Set storage cidHashs = node2cidHashs[addr];

        Paging.Page memory page = Paging.getPage(cidHashs.length(), pageSize, pageNumber);

        uint256 start = page.pageNumber.sub(1).mul(page.pageSize);

        string[] memory result = new string[](page.pageRecords);
        for(uint256 i=0; i<page.pageRecords; i++) {
            result[i] = cidHash2cid[cidHashs.at(start+i)];
        }

        return (result, page);
    }
}
