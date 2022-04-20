pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import "./ExternalStorage.sol";
import "../interfaces/storages/INodeStorage.sol";
import "../lib/EnumerableSet.sol";
import "../lib/Paging.sol";

contract NodeStorage is ExternalStorage, INodeStorage {
    using EnumerableSet for EnumerableSet.Bytes32Set;
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(address=>NodeItem) nodes;
    EnumerableSet.AddressSet nodeAddrs;
    EnumerableSet.AddressSet onlineNodeAddrs;

    mapping(address=>EnumerableSet.Bytes32Set) node2cidHashs;
    mapping(bytes32=>string) cidHash2cid;

    constructor(address _manager) public ExternalStorage(_manager) {}

    function newNode(address addr, string calldata pid, uint256 space, string calldata ext) external {
        nodes[addr] = NodeItem(pid,
            Status.Registered,
            ServiceInfo(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, now, 0),
            StorageInfo(0, space),
            0, BlockInfo(0, 0), ext, 0, true);

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

    function node(address addr) public returns (NodeItem memory) {
        return nodes[addr];
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
        if(Status.Online == status) {
            onlineNodeAddrs.add(addr);
        } else if(Status.Maintain == status) {
            onlineNodeAddrs.remove(addr);
            nodes[addr].serviceInfo.maintainCount = nodes[addr].serviceInfo.maintainCount.add(1);
        } else if(Status.Offline == status) {
            onlineNodeAddrs.remove(addr);
            nodes[addr].serviceInfo.offlineCount = nodes[addr].serviceInfo.offlineCount.add(1);
        } else if(Status.DeRegistered == status) {
            onlineNodeAddrs.remove(addr);
        }
    }

    function totalTaskAddAcceptTimeoutCount(address addr) external view returns (uint256) {
        return nodes[addr].serviceInfo.totalTaskAddAcceptTimeoutCount;
    }

    function totalTaskAddTimeoutCount(address addr) external view returns (uint256) {
        return nodes[addr].serviceInfo.totalTaskAddTimeoutCount;
    }

    function totalTaskDeleteAcceptTimeoutCount(address addr) external view returns (uint256) {
        return nodes[addr].serviceInfo.totalTaskDeleteAcceptTimeoutCount;
    }

    function totalTaskDeleteTimeoutCount(address addr) external view returns (uint256) {
        return nodes[addr].serviceInfo.totalTaskDeleteTimeoutCount;
    }

    function taskAddAcceptTimeoutCount(address addr) external view returns (uint256) {
        return nodes[addr].serviceInfo.taskAddAcceptTimeoutCount;
    }

    function taskAddTimeoutCount(address addr) external view returns (uint256) {
        return nodes[addr].serviceInfo.taskAddTimeoutCount;
    }

    function taskDeleteAcceptTimeoutCount(address addr) external view returns (uint256) {
        return nodes[addr].serviceInfo.taskDeleteAcceptTimeoutCount;
    }

    function taskDeleteTimeoutCount(address addr) external view returns (uint256) {
        return nodes[addr].serviceInfo.taskDeleteTimeoutCount;
    }

    function upTaskAddAcceptTimeoutCount(address addr) external {
        nodes[addr].serviceInfo.totalTaskAddAcceptTimeoutCount.add(1);
        nodes[addr].serviceInfo.taskAddAcceptTimeoutCount.add(1);
    }

    function upTaskAddTimeoutCount(address addr) external {
        nodes[addr].serviceInfo.totalTaskAddTimeoutCount.add(1);
        nodes[addr].serviceInfo.taskAddTimeoutCount.add(1);
    }

    function upTaskDeleteAcceptTimeoutCount(address addr) external {
        nodes[addr].serviceInfo.totalTaskDeleteAcceptTimeoutCount.add(1);
        nodes[addr].serviceInfo.taskDeleteAcceptTimeoutCount.add(1);
    }

    function upTaskDeleteTimeoutCount(address addr) external {
        nodes[addr].serviceInfo.totalTaskDeleteTimeoutCount.add(1);
        nodes[addr].serviceInfo.taskDeleteTimeoutCount.add(1);
    }

    function resetTaskAddAcceptTimeoutCount(address addr) external {
        nodes[addr].serviceInfo.taskAddAcceptTimeoutCount = 0;
    }

    function resetTaskAddTimeoutCount(address addr) external {
        nodes[addr].serviceInfo.taskAddTimeoutCount = 0;
    }

    function resetTaskDeleteAcceptTimeoutCount(address addr) external {
        nodes[addr].serviceInfo.taskDeleteAcceptTimeoutCount = 0;
    }

    function resetTaskDeleteTimeoutCount(address addr) external {
        nodes[addr].serviceInfo.taskDeleteTimeoutCount = 0;
    }

    function totalTaskTimeoutCount(address addr) external view returns (uint256) {
        INodeStorage.ServiceInfo storage serviceInfo = nodes[addr].serviceInfo;
        return serviceInfo.taskAddAcceptTimeoutCount +
                serviceInfo.taskAddTimeoutCount +
                serviceInfo.taskDeleteAcceptTimeoutCount +
                serviceInfo.taskDeleteTimeoutCount;
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

    function blockInfo(address addr) external view returns (BlockInfo memory) {
        return nodes[addr].blockInfo;
    }

    function setCurrentBlock(address addr, uint256 block) external {
        nodes[addr].blockInfo.currentBlock = block;
    }

    function setTargetBlock(address addr, uint256 block) external {
        nodes[addr].blockInfo.targetBlock = block;
    }

    function ext(address addr) external view returns (string memory) {
        return nodes[addr].ext;
    }
    function setExt(address addr, string calldata ext) external {
        nodes[addr].ext = ext;
    }

    function storageInfo(address addr) public view returns (StorageInfo memory) {
        return nodes[addr].storageInfo;
    }

    function serviceInfo(address addr) public view returns (ServiceInfo memory) {
        return nodes[addr].serviceInfo;
    }

    function freeSpace(address addr) external view returns (uint256) {
        return nodes[addr].storageInfo.space.sub(nodes[addr].storageInfo.used);
    }

    function pid(address addr) public view returns (string memory) {
        return nodes[addr].pid;
    }

    function nodeAddresses(uint256 pageSize, uint256 pageNumber) public view returns (address[] memory, Paging.Page memory) {
        Paging.Page memory page = Paging.getPage(nodeAddrs.length(), pageSize, pageNumber);
        uint256 start = page.pageNumber.sub(1).mul(page.pageSize);
        address[] memory result = new address[](page.pageRecords);
        for(uint256 i=0; i<page.pageRecords; i++) {
            result[i] = nodeAddrs.at(start+i);
        }
        return (result, page);
    }

    function onlineNodeAddresses(uint256 pageSize, uint256 pageNumber) public view returns (address[] memory, Paging.Page memory) {
        Paging.Page memory page = Paging.getPage(onlineNodeAddrs.length(), pageSize, pageNumber);
        uint256 start = page.pageNumber.sub(1).mul(page.pageSize);
        address[] memory result = new address[](page.pageRecords);
        for(uint256 i=0; i<page.pageRecords; i++) {
            result[i] = onlineNodeAddrs.at(start+i);
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
