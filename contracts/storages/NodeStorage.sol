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

    function newNode(address addr, uint256 totalSpace, string calldata ext) external {
        nodes[addr] = NodeItem(pid,
            Status.Registered,
            ServiceInfo(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, now, 0),
            Space(totalSpace, 0, totalSpace),
            0, TaskBlock(0, 0), ext, 0, true);

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

    function getNode(address addr) public returns (NodeItem memory) {
        return nodes[addr];
    }

    function getServiceInfo(address addr) public view returns (ServiceInfo memory) {
        return nodes[addr].serviceInfo;
    }

    function getSpace(address addr) public view returns (Space memory) {
        return nodes[addr].storageInfo;
    }

    function getTaskBlock(address addr) external view returns (TaskBlock memory) {
        return nodes[addr].blockInfo;
    }


    function getStatus(address addr) external view returns (Status) {
        return nodes[addr].status;
    }

    function setStatus(address addr, Status status) external {
        nodes[addr].status = status;
    }

    function getContinuousTimeoutCount(address addr) external view returns (uint256) {
        return nodes[addr].serviceInfo.continuousTimeoutCount;
    }

    function setContinuousTimeoutCount(address addr, uint256 value) external {
        nodes[addr].serviceInfo.continuousTimeoutCount = value;
    }

    function getMaintainCount(address addr) external view returns (uint256) {
        return nodes[addr].serviceInfo.maintainCount;
    }

    function setMaintainCount(address addr, uint256 value) external {
        nodes[addr].serviceInfo.maintainCount = value;
    }

    function getOfflineCount(address addr) external view returns (uint256) {
        return nodes[addr].serviceInfo.offlineCount;
    }

    function setOfflineCount(address addr, uint256 value) external {
        nodes[addr].serviceInfo.offlineCount = value;
    }

    function getTaskAddAcceptTimeoutCount(address addr) external view returns (uint256) {
        return nodes[addr].serviceInfo.taskAddAcceptTimeoutCount;
    }

    function setTaskAddAcceptTimeoutCount(address addr, uint256 value) external {
        nodes[addr].serviceInfo.taskAddAcceptTimeoutCount = value;
    }

    function getTaskAddTimeoutCount(address addr) external view returns (uint256) {
        return nodes[addr].serviceInfo.taskAddTimeoutCount;
    }

    function setTaskAddTimeoutCount(address addr, uint256 value) external {
        nodes[addr].serviceInfo.taskAddTimeoutCount = value;
    }

    function getTaskDeleteAcceptTimeoutCount(address addr) external view returns (uint256) {
        return nodes[addr].serviceInfo.taskDeleteAcceptTimeoutCount;
    }

    function setTaskDeleteAcceptTimeoutCount(address addr, uint256 value) external {
        nodes[addr].serviceInfo.taskDeleteAcceptTimeoutCount = value;
    }

    function getTaskDeleteTimeoutCount(address addr) external view returns (uint256) {
        return nodes[addr].serviceInfo.taskDeleteTimeoutCount;
    }

    function setTaskDeleteTimeoutCount(address addr, uint256 value) external {
        nodes[addr].serviceInfo.taskDeleteTimeoutCount = value;
    }

    function getTotalSpace(address addr) external view returns (uint256) {
        return nodes[addr].space.total;
    }

    function setTotalSpace(address addr, uint256 value) external {
        nodes[addr].space.total = value;
    }

    function getUsedSpace(address addr) external view returns (uint256) {
        return nodes[addr].space.used;
    }

    function setUsedSpace(address addr, uint256 value) external {
        nodes[addr].space.used = value;
    }

    function getCurrentTaskBlock(address addr) external view returns (uint256) {
        return nodes[addr].taskBlock.current;
    }

    function setCurrentTaskBlock(address addr, uint256 value) external {
        nodes[addr].taskBlock.current = value;
    }

    function getTargetTaskBlock(address addr) external view returns (uint256) {
        return nodes[addr].taskBlock.target;
    }

    function setTargetTaskBlock(address addr, uint256 value) external {
        nodes[addr].taskBlock.target = value;
    }

    function getExt(address addr) external view returns (string memory) {
        return nodes[addr].ext;
    }

    function setExt(address addr, string calldata ext) external {
        nodes[addr].ext = ext;
    }

//////////////////
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

    function upTaskAddAcceptTimeoutCount(address addr) external {
        nodes[addr].serviceInfo.taskAddAcceptTimeoutCount.add(1);
        nodes[addr].serviceInfo._taskAddAcceptTimeoutCount.add(1);
    }

    function upTaskAddTimeoutCount(address addr) external {
        nodes[addr].serviceInfo.taskAddTimeoutCount.add(1);
        nodes[addr].serviceInfo._taskAddTimeoutCount.add(1);
    }

    function upTaskDeleteAcceptTimeoutCount(address addr) external {
        nodes[addr].serviceInfo.taskDeleteAcceptTimeoutCount.add(1);
        nodes[addr].serviceInfo._taskDeleteAcceptTimeoutCount.add(1);
    }

    function upTaskDeleteTimeoutCount(address addr) external {
        nodes[addr].serviceInfo.taskDeleteTimeoutCount.add(1);
        nodes[addr].serviceInfo._taskDeleteTimeoutCount.add(1);
    }

    function resetTaskAddAcceptTimeoutCount(address addr) external {
        nodes[addr].serviceInfo._taskAddAcceptTimeoutCount = 0;
    }

    function resetTaskAddTimeoutCount(address addr) external {
        nodes[addr].serviceInfo._taskAddTimeoutCount = 0;
    }

    function resetTaskDeleteAcceptTimeoutCount(address addr) external {
        nodes[addr].serviceInfo._taskDeleteAcceptTimeoutCount = 0;
    }

    function resetTaskDeleteTimeoutCount(address addr) external {
        nodes[addr].serviceInfo._taskDeleteTimeoutCount = 0;
    }

    function totalTaskTimeoutCount(address addr) external view returns (uint256) {
        INodeStorage.ServiceInfo storage serviceInfo = nodes[addr].serviceInfo;
        return serviceInfo._taskAddAcceptTimeoutCount +
                serviceInfo._taskAddTimeoutCount +
                serviceInfo._taskDeleteAcceptTimeoutCount +
                serviceInfo._taskDeleteTimeoutCount;
    }

    function maintainCount(address addr) public view returns (uint256) {
        return nodes[addr].serviceInfo.maintainCount;
    }

    function upMaintainCount(address addr) external {
        nodes[addr].serviceInfo.maintainCount.add(1);
    }

    function offlineCount(address addr) public view returns (uint256) {
        return nodes[addr].serviceInfo.offlineCount;
    }

    function upOfflineCount(address addr) external {
        nodes[addr].serviceInfo.offlineCount.add(1);
    }

    function starve(address addr) public view returns (uint256) {
        return nodes[addr].starve;
    }

    function setStarve(address addr, uint256 starve) public {
        nodes[addr].starve = starve;
    }



    function setCurrentBlock(address addr, uint256 block) external {
        nodes[addr].blockInfo.current = block;
    }

    function setTargetBlock(address addr, uint256 block) external {
        nodes[addr].blockInfo.target = block;
    }





    function freeSpace(address addr) external view returns (uint256) {
        return nodes[addr].storageInfo.total.sub(nodes[addr].storageInfo.used);
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
