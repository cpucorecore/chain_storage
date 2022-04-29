pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import "./ExternalStorage.sol";
import "../interfaces/storages/INodeStorage.sol";
import "../lib/EnumerableSet.sol";
import "../lib/Paging.sol";

contract NodeStorage is ExternalStorage, INodeStorage {
    using EnumerableSet for EnumerableSet.Bytes32Set;
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(address=>NodeItem) private nodes;
    EnumerableSet.AddressSet private nodeAddrs;
    EnumerableSet.AddressSet private onlineNodeAddrs;

    mapping(address=>EnumerableSet.Bytes32Set) private node2cidHashs;
    mapping(bytes32=>string) private cidHash2cid;

    mapping(string=>uint256) private cid2addFileFailedCount;

    constructor(address _manager) public ExternalStorage(_manager) {}

    function exist(address addr) external view returns (bool) {
        return nodes[addr].exist;
    }

    function newNode(address addr, uint256 totalSpace, string calldata ext) external {
        nodes[addr] = NodeItem(Status.Registered,
            ServiceInfo(0, 0, 0, 0, 0, 0, 0),
            StorageSpaceInfo(totalSpace, 0),
            0, ext, true);

        nodeAddrs.add(addr);
    }

    function deleteNode(address addr) public {
        delete nodes[addr];
        delete node2cidHashs[addr];
        nodeAddrs.remove(addr);
        onlineNodeAddrs.remove(addr);
    }

    function getNode(address addr) external view returns (NodeItem memory) {
        return nodes[addr];
    }

    function isNodeOnline(address addr) external view returns (bool) {
        return onlineNodeAddrs.contains(addr);
    }

    function addOnlineNode(address addr) external {
        onlineNodeAddrs.add(addr);
    }

    function deleteOnlineNode(address addr) external {
        onlineNodeAddrs.remove(addr);
    }

    function getServiceInfo(address addr) public view returns (ServiceInfo memory) {
        return nodes[addr].serviceInfo;
    }

    function getStorageSpaceInfo(address addr) public view returns (StorageSpaceInfo memory) {
        return nodes[addr].storageInfo;
    }

    function getMaxFinishedTid(address addr) external view returns (uint256) {
        return nodes[addr].maxFinishedTid;
    }

    function setMaxFinishedTid(address addr, uint256 tid) external {
        nodes[addr].maxFinishedTid = tid;
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

    function getTaskAddFileFinishCount(address addr) external view returns (uint256) {
        return nodes[addr].serviceInfo.taskAddFileFinishCount;
    }

    function setTaskAddFileFinishCount(address addr, uint256 value) external {
        nodes[addr].serviceInfo.taskAddFileFinishCount = value;
    }

    function getTaskAddFileFailCount(address addr) external view returns (uint256) {
        return nodes[addr].serviceInfo.taskAddFileFailCount;
    }

    function setTaskAddFileFailCount(address addr, uint256 value) external {
        nodes[addr].serviceInfo.taskAddFileFailCount = value;
    }

    function getTaskDeleteFileFinishCount(address addr) external view returns (uint256) {
        return nodes[addr].serviceInfo.taskDeleteFileFinishCount;
    }

    function setTaskDeleteFileFinishCount(address addr, uint256 value) external {
        nodes[addr].serviceInfo.taskDeleteFileFinishCount = value;
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

    function getStorageFree(address addr) external view returns (uint256) {
        if(nodes[addr].storageInfo.used > nodes[addr].storageInfo.total) return 0;
        return nodes[addr].storageInfo.total.sub(nodes[addr].storageInfo.used);
    }

    function getStorageTotal(address addr) external view returns (uint256) {
        return nodes[addr].storageInfo.total;
    }

    function setStorageTotal(address addr, uint256 value) external {
        nodes[addr].storageInfo.total = value;
    }

    function getStorageUsed(address addr) external view returns (uint256) {
        return nodes[addr].storageInfo.used;
    }

    function setStorageUsed(address addr, uint256 value) external {
        nodes[addr].storageInfo.used = value;
    }

    function getExt(address addr) external view returns (string memory) {
        return nodes[addr].ext;
    }

    function setExt(address addr, string calldata ext) external {
        nodes[addr].ext = ext;
    }

    function getAllNodeAddresses() public view returns (address[] memory) {
        return nodeAddrs.values();
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

    function getAllOnlineNodeAddresses() public view returns (address[] memory) {
        return onlineNodeAddrs.values();
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

    function getNodeCidsNumber(address addr) external view returns (uint256) {
        return node2cidHashs[addr].length();
    }

    function getNodeCids(address addr) external view returns (string[] memory) {
        uint256 length = node2cidHashs[addr].length();
        string[] memory result = new string[](length);
        for(uint256 i=0; i<length; i++) {
            result[i] = cidHash2cid[node2cidHashs[addr].at(i)];
        }
        return result;
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

    function getAddFileFailedCount(string calldata cid) external view returns (uint256) {
        return cid2addFileFailedCount[cid];
    }

    function setAddFileFailedCount(string calldata cid, uint256 count) external {
        cid2addFileFailedCount[cid] = count;
    }
}
