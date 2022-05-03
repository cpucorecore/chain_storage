pragma solidity ^0.5.2;
pragma experimental ABIEncoderV2;

import "./storages/ExternalStorage.sol";
import "./interfaces/storages/INodeStorage.sol";
import "./lib/EnumerableSet.sol";
import "./lib/Paging.sol";

contract NodeStorage is ExternalStorage, INodeStorage {
    using EnumerableSet for EnumerableSet.Bytes32Set;
    using EnumerableSet for EnumerableSet.AddressSet;

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

    function newNode(address node, uint256 totalSpace, string calldata ext) external {
        require(!nodes[node].exist, contractName.concat(": node exist"));

        nodes[node] = NodeItem(Status.Registered,
            ServiceInfo(0, 0, 0, 0, 0, 0, 0),
            StorageSpaceInfo(totalSpace, 0),
            0, ext, true);

        nodeAddrs.add(node);
    }

    function deleteNode(address addr) public {
        require(nodes[addr].exist, contractName.concat(": node not exist"));

        delete nodes[addr];
        delete node2cidHashes[addr];
        nodeAddrs.remove(addr);
        onlineNodeAddrs.remove(addr);
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

    function getStorageSpaceInfo(address addr) public view returns (uint256, uint256) { // (used, total)
        return (nodes[addr].storageInfo.used, nodes[addr].storageInfo.total);
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

    function useStorage(address addr, uint256 size) external {
        require(nodes[addr].storageInfo.used.add(size) <= nodes[addr].storageInfo.total, contractName.concat(": space not enough"));
        nodes[addr].storageInfo.used = nodes[addr].storageInfo.used.add(size);
    }

    function freeStorage(address addr, uint256 size) external {
        require(size <= nodes[addr].storageInfo.used, contractName.concat("free size can not big than used size"));
        nodes[addr].storageInfo.used = nodes[addr].storageInfo.used.sub(size);
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
        bytes32 cidHash = keccak256(bytes(cid));
        node2cidHashes[addr].add(cidHash);
        cidHash2cid[cidHash] = cid;
    }

    function removeNodeCid(address addr, string calldata cid) external {
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
        cid2addFileFailedCount[cid] = count;
    }

    function getTotalNodeNumber() external view returns (uint256) {
        return nodeAddrs.length();
    }

    function getTotalOnlineNodeNumber() external view returns (uint256) {
        return onlineNodeAddrs.length();
    }
}
