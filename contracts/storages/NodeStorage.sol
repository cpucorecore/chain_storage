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
        nodes[addr] = NodeItem(Status.Registered,
            ServiceInfo(0, 0, 0, 0, 0, 0),
            SpaceInfo(totalSpace, 0),
            TasksProgress(0, 0), ext, true);

        EnumerableSet.Bytes32Set memory cidHashs;
        node2cidHashs[addr] = cidHashs;

        nodeAddrs.add(addr);
    }

    function deleteNode(address addr) public {
        delete nodes[addr];
        delete node2cidHashs[addr];
        nodeAddrs.remove(addr);
    }

    function exist(address addr) external view returns (bool) {
        return nodes[addr].exist;
    }

    function getNode(address addr) external view returns (NodeItem memory) {
        return nodes[addr];
    }

    function getServiceInfo(address addr) public view returns (ServiceInfo memory) {
        return nodes[addr].serviceInfo;
    }

    function getSpaceInfo(address addr) public view returns (SpaceInfo memory) {
        return nodes[addr].spaceInfo;
    }

    function getTasksProgress(address addr) external view returns (TasksProgress memory) {
        return nodes[addr].tasksProgress;
    }

    function getStatus(address addr) external view returns (Status) {
        return nodes[addr].status;
    }

    function setStatus(address addr, Status status) external {
        nodes[addr].status = status;
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

    function getTaskFinishCount(address addr) external view returns (uint256) {
        return nodes[addr].serviceInfo.taskFinishCount;
    }

    function setTaskFinishCount(address addr, uint256 value) external {
        nodes[addr].serviceInfo.taskFinishCount = value;
    }

    function getTaskFailCount(address addr) external view returns (uint256) {
        return nodes[addr].serviceInfo.taskFailCount;
    }

    function setTaskFailCount(address addr, uint256 value) external {
        nodes[addr].serviceInfo.taskFailCount = value;
    }

    function getTaskAcceptTimeoutCount(address addr) external view returns (uint256) {
        return nodes[addr].serviceInfo.taskAcceptTimeoutCount;
    }

    function setTaskAcceptTimeoutCount(address addr, uint256 value) external {
        nodes[addr].serviceInfo.taskAcceptTimeoutCount = value;
    }

    function getTaskTimeoutCount(address addr) external view returns (uint256) {
        return nodes[addr].serviceInfo.taskTimeoutCount;
    }

    function setTaskTimeoutCount(address addr, uint256 value) external {
        nodes[addr].serviceInfo.taskTimeoutCount = value;
    }

    function getFreeSpace(address addr) external view returns (uint256) {
        if(nodes[addr].spaceInfo.used > nodes[addr].spaceInfo.total) return 0;
        return nodes[addr].spaceInfo.total.sub(nodes[addr].spaceInfo.used);
    }

    function getTotalSpace(address addr) external view returns (uint256) {
        return nodes[addr].spaceInfo.total;
    }

    function setTotalSpace(address addr, uint256 value) external {
        nodes[addr].spaceInfo.total = value;
    }

    function getUsedSpace(address addr) external view returns (uint256) {
        return nodes[addr].spaceInfo.used;
    }

    function setUsedSpace(address addr, uint256 value) external {
        nodes[addr].spaceInfo.used = value;
    }

    function getTasksProgressCurrentTime(address addr) external view returns (uint256) {
        return nodes[addr].tasksProgress.currentTime;
    }

    function setTasksProgressCurrentTime(address addr, uint256 value) external {
        nodes[addr].tasksProgress.currentTime = value;
    }

    function getTasksProgressTargetTime(address addr) external view returns (uint256) {
        return nodes[addr].tasksProgress.targetTime;
    }

    function getTasksProgressTargetTime(address addr, uint256 value) external {
        nodes[addr].tasksProgress.targetTime = value;
    }

    function getExt(address addr) external view returns (string memory) {
        return nodes[addr].ext;
    }

    function setExt(address addr, string calldata ext) external {
        nodes[addr].ext = ext;
    }

    function getAllNodeAddresses(uint256 pageSize, uint256 pageNumber) public view returns (address[] memory, Paging.Page memory) {
        Paging.Page memory page = Paging.getPage(nodeAddrs.length(), pageSize, pageNumber);
        uint256 start = page.pageNumber.sub(1).mul(page.pageSize);
        address[] memory result = new address[](page.pageRecords);
        for(uint256 i=0; i<page.pageRecords; i++) {
            result[i] = nodeAddrs.at(start+i);
        }
        return (result, page);
    }

    function getAllOnlineNodeAddresses(uint256 pageSize, uint256 pageNumber) public view returns (address[] memory, Paging.Page memory) {
        Paging.Page memory page = Paging.getPage(onlineNodeAddrs.length(), pageSize, pageNumber);
        uint256 start = page.pageNumber.sub(1).mul(page.pageSize);
        address[] memory result = new address[](page.pageRecords);
        for(uint256 i=0; i<page.pageRecords; i++) {
            result[i] = onlineNodeAddrs.at(start+i);
        }
        return (result, page);
    }

    function getNodeCids(address addr, uint256 pageSize, uint256 pageNumber) public view returns (string[] memory, Paging.Page memory) {
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
