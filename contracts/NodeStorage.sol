pragma solidity ^0.5.2;
pragma experimental ABIEncoderV2;

import "./storages/ExternalStorage.sol";
import "./interfaces/storages/INodeStorage.sol";
import "./interfaces/storages/INodeStorageViewer.sol";
import "./lib/EnumerableSet.sol";
import "./lib/Paging.sol";

contract NodeStorage is ExternalStorage, INodeStorage, INodeStorageViewer {
    using EnumerableSet for EnumerableSet.Bytes32Set;
    using EnumerableSet for EnumerableSet.AddressSet;

    struct ServiceInfo {
        uint256 maintainCount;
        uint256 offlineCount;
        uint256 taskAddFileFinishCount;
        uint256 taskAddFileFailCount;
        uint256 taskDeleteFileFinishCount;
        uint256 taskAcceptTimeoutCount;
        uint256 taskTimeoutCount;
    }

    struct NodeItem {
        uint8 status;
        ServiceInfo serviceInfo;
        uint256 maxFinishedTid;
        uint256 storageUsed;
        uint256 storageTotal;
        string ext;
        bool exist;
    }

    mapping(address=>NodeItem) private nodes;
    EnumerableSet.AddressSet private nodeAddrs;
    EnumerableSet.AddressSet private onlineNodeAddrs;

    mapping(address=>EnumerableSet.Bytes32Set) private node2cidHashes;
    mapping(bytes32=>string) private cidHash2cid;

    mapping(string=>uint256) private cid2addFileFailedCount;

    constructor(address _manager) public ExternalStorage(_manager) {}

    function exist(address addr) external view returns (bool) {
        return nodes[addr].exist;
    }

    function newNode(address node, uint256 storageTotal, string calldata ext) external {
        mustManager(managerName);
        require(!nodes[node].exist, contractName.concat(": node exist"));

        nodes[node] = NodeItem(NodeRegistered,
            ServiceInfo(0, 0, 0, 0, 0, 0, 0),
            0,
            storageTotal,
            0, ext, true);

        nodeAddrs.add(node);
    }

    function deleteNode(address addr) external {
        mustManager(managerName);
        require(nodes[addr].exist, contractName.concat(": node not exist"));

        delete nodes[addr];
        delete node2cidHashes[addr];
        nodeAddrs.remove(addr);
        onlineNodeAddrs.remove(addr);
    }

    function useStorage(address addr, uint256 value) external {
        nodes[addr].storageUsed = nodes[addr].storageUsed.add(value);
    }

    function freeStorage(address addr, uint256 value) external {
        nodes[addr].storageUsed = nodes[addr].storageUsed.sub(value);
    }

    function isNodeOnline(address addr) external view returns (bool) {
        return onlineNodeAddrs.contains(addr);
    }

    function addOnlineNode(address addr) external {
        mustManager(managerName);
        onlineNodeAddrs.add(addr);
    }

    function deleteOnlineNode(address addr) external {
        mustManager(managerName);
        onlineNodeAddrs.remove(addr);
    }

    function offline(address addr) external {
        mustManager(managerName);
        require(nodes[addr].exist, "NodeFileHandler: node not exist");

        require(NodeOnline == nodes[addr].status, "NodeFileHandler: wrong status");
        nodes[addr].status = NodeOffline;
        if(onlineNodeAddrs.contains(addr)) {
            onlineNodeAddrs.remove(addr);
        }

        nodes[addr].serviceInfo.offlineCount = nodes[addr].serviceInfo.offlineCount.add(1);
    }

    function getServiceInfo(address addr) public view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256) {
        ServiceInfo storage si = nodes[addr].serviceInfo;
        return (si.maintainCount,
                si.offlineCount,
                si.taskAddFileFinishCount,
                si.taskAddFileFailCount,
                si.taskDeleteFileFinishCount,
                si.taskAcceptTimeoutCount,
                si.taskTimeoutCount);
    }

    function getStorageInfo(address addr) public view returns (uint256, uint256) {
        return (nodes[addr].storageUsed, nodes[addr].storageTotal);
    }

    function getMaxFinishedTid(address addr) external view returns (uint256) {
        return nodes[addr].maxFinishedTid;
    }

    function setMaxFinishedTid(address addr, uint256 tid) external {
        mustManager(managerName);
        nodes[addr].maxFinishedTid = tid;
    }

    function getStatus(address addr) external view returns (uint8) {
        return nodes[addr].status;
    }

    function setStatus(address addr, uint8 status) external {
        mustManager(managerName);
        nodes[addr].status = status;
    }

    function getMaintainCount(address addr) external view returns (uint256) {
        return nodes[addr].serviceInfo.maintainCount;
    }

    function setMaintainCount(address addr, uint256 value) external {
        mustManager(managerName);
        nodes[addr].serviceInfo.maintainCount = value;
    }

    function getOfflineCount(address addr) external view returns (uint256) {
        return nodes[addr].serviceInfo.offlineCount;
    }

    function setOfflineCount(address addr, uint256 value) external {
        mustManager(managerName);
        nodes[addr].serviceInfo.offlineCount = value;
    }

    function getTaskAddFileFinishCount(address addr) external view returns (uint256) {
        return nodes[addr].serviceInfo.taskAddFileFinishCount;
    }

    function setTaskAddFileFinishCount(address addr, uint256 value) external {
        mustManager(managerName);
        nodes[addr].serviceInfo.taskAddFileFinishCount = value;
    }

    function getTaskAddFileFailCount(address addr) external view returns (uint256) {
        return nodes[addr].serviceInfo.taskAddFileFailCount;
    }

    function setTaskAddFileFailCount(address addr, uint256 value) external {
        mustManager(managerName);
        nodes[addr].serviceInfo.taskAddFileFailCount = value;
    }

    function getTaskDeleteFileFinishCount(address addr) external view returns (uint256) {
        return nodes[addr].serviceInfo.taskDeleteFileFinishCount;
    }

    function setTaskDeleteFileFinishCount(address addr, uint256 value) external {
        mustManager(managerName);
        nodes[addr].serviceInfo.taskDeleteFileFinishCount = value;
    }

    function getTaskAcceptTimeoutCount(address addr) external view returns (uint256) {
        return nodes[addr].serviceInfo.taskAcceptTimeoutCount;
    }

    function setTaskAcceptTimeoutCount(address addr, uint256 value) external {
        mustManager(managerName);
        nodes[addr].serviceInfo.taskAcceptTimeoutCount = value;
    }

    function getTaskTimeoutCount(address addr) external view returns (uint256) {
        return nodes[addr].serviceInfo.taskTimeoutCount;
    }

    function setTaskTimeoutCount(address addr, uint256 value) external {
        mustManager(managerName);
        nodes[addr].serviceInfo.taskTimeoutCount = value;
    }

    function getStorageFree(address addr) external view returns (uint256) {
        if(nodes[addr].storageUsed > nodes[addr].storageTotal) return 0;
        return nodes[addr].storageTotal.sub(nodes[addr].storageUsed);
    }

    function getStorageTotal(address addr) external view returns (uint256) {
        return nodes[addr].storageTotal;
    }

    function setStorageTotal(address addr, uint256 value) external {
        mustManager(managerName);
        nodes[addr].storageUsed = value;
    }

    function getStorageUsed(address addr) external view returns (uint256) {
        return nodes[addr].storageUsed;
    }

    function getExt(address addr) external view returns (string memory) {
        return nodes[addr].ext;
    }

    function setExt(address addr, string calldata ext) external {
        mustManager(managerName);
        nodes[addr].ext = ext;
    }

    function getAllNodeAddresses() public view returns (address[] memory) {
        return nodeAddrs.values();
    }

    function getAllNodeAddresses(uint256 pageSize, uint256 pageNumber) public view returns (address[] memory, bool) {
        Paging.Page memory page = Paging.getPage(nodeAddrs.length(), pageSize, pageNumber);
        uint256 start = page.pageNumber.sub(1).mul(page.pageSize);
        address[] memory result = new address[](page.pageRecords);
        for(uint256 i=0; i<page.pageRecords; i++) {
            result[i] = nodeAddrs.at(start+i);
        }
        return (result, page.pageNumber == page.totalPages);
    }

    function getAllOnlineNodeAddresses() public view returns (address[] memory) {
        return onlineNodeAddrs.values();
    }

    function getAllOnlineNodeAddresses(uint256 pageSize, uint256 pageNumber) public view returns (address[] memory, bool) {
        Paging.Page memory page = Paging.getPage(onlineNodeAddrs.length(), pageSize, pageNumber);
        uint256 start = page.pageNumber.sub(1).mul(page.pageSize);
        address[] memory result = new address[](page.pageRecords);
        for(uint256 i=0; i<page.pageRecords; i++) {
            result[i] = onlineNodeAddrs.at(start+i);
        }
        return (result, page.pageNumber == page.totalPages);
    }

    function cidExist(address addr, string calldata cid) external view returns (bool) {
        bytes32 cidHash = keccak256(bytes(cid));
        return node2cidHashes[addr].contains(cidHash);
    }

    function addNodeCid(address addr, string calldata cid) external {
        mustManager(managerName);
        bytes32 cidHash = keccak256(bytes(cid));
        node2cidHashes[addr].add(cidHash);
        cidHash2cid[cidHash] = cid;
    }

    function removeNodeCid(address addr, string calldata cid) external {
        mustManager(managerName);
        bytes32 cidHash = keccak256(bytes(cid));
        node2cidHashes[addr].remove(cidHash);
        delete cidHash2cid[cidHash];
    }

    function getNodeCidsNumber(address addr) external view returns (uint256) {
        return node2cidHashes[addr].length();
    }

    function getNodeCids(address addr) external view returns (string[] memory) {
        uint256 length = node2cidHashes[addr].length();
        string[] memory result = new string[](length);
        for(uint256 i=0; i<length; i++) {
            result[i] = cidHash2cid[node2cidHashes[addr].at(i)];
        }
        return result;
    }

    function getNodeCids(address addr, uint256 pageSize, uint256 pageNumber) public view returns (string[] memory, bool) {
        EnumerableSet.Bytes32Set storage cidHashs = node2cidHashes[addr];
        Paging.Page memory page = Paging.getPage(cidHashs.length(), pageSize, pageNumber);
        uint256 start = page.pageNumber.sub(1).mul(page.pageSize);
        string[] memory result = new string[](page.pageRecords);
        for(uint256 i=0; i<page.pageRecords; i++) {
            result[i] = cidHash2cid[cidHashs.at(start+i)];
        }
        return (result, page.pageNumber == page.totalPages);
    }

    function getAddFileFailedCount(string calldata cid) external view returns (uint256) {
        return cid2addFileFailedCount[cid];
    }

    function setAddFileFailedCount(string calldata cid, uint256 count) external {
        mustManager(managerName);
        cid2addFileFailedCount[cid] = count;
    }

    function getTotalNodeNumber() external view returns (uint256) {
        return nodeAddrs.length();
    }

    function getTotalOnlineNodeNumber() external view returns (uint256) {
        return onlineNodeAddrs.length();
    }
}
