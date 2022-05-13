pragma solidity ^0.5.2;
pragma experimental ABIEncoderV2;

import "./storages/ExternalStorage.sol";
import "./interfaces/storages/INodeStorage.sol";
import "./lib/EnumerableSet.sol";
import "./lib/Paging.sol";
import "./lib/StorageSpaceManager.sol";

contract NodeStorage is ExternalStorage, INodeStorage {
    using StorageSpaceManager for StorageSpaceManager.StorageSpace;
    using EnumerableSet for EnumerableSet.Bytes32Set;
    using EnumerableSet for EnumerableSet.AddressSet;

    struct NodeItem {
        uint256 status;
        StorageSpaceManager.StorageSpace storageSpace;
        uint256 maxFinishedTid;
        string ext;
    }

    mapping(address=>NodeItem) private nodes;
    EnumerableSet.AddressSet private nodeAddrs;
    EnumerableSet.AddressSet private onlineNodeAddrs;
    mapping(string=>uint256) private cid2addFileFailedCount;

    constructor(address _manager) public ExternalStorage(_manager) {}

    function exist(address addr) public view returns (bool) {
        return DefaultStatus != nodes[addr].status;
    }

    function newNode(address addr, uint256 storageTotal, string calldata ext) external {
        mustManager(managerName);
        nodes[addr] = NodeItem(NodeRegistered, StorageSpaceManager.StorageSpace(0, storageTotal), 0, ext);
        nodeAddrs.add(addr);
    }

    function deleteNode(address addr) external {
        mustManager(managerName);
        delete nodes[addr];
        nodeAddrs.remove(addr);
        onlineNodeAddrs.remove(addr);
    }

    function useStorage(address addr, uint256 size) external {
        nodes[addr].storageSpace.useSpace(size);
    }

    function freeStorage(address addr, uint256 size) external {
        nodes[addr].storageSpace.unUseSpace(size);
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

    function getStorageInfo(address addr) public view returns (uint256, uint256) {
        return (nodes[addr].storageSpace.used, nodes[addr].storageSpace.total);
    }

    function getMaxFinishedTid(address addr) external view returns (uint256) {
        return nodes[addr].maxFinishedTid;
    }

    function setMaxFinishedTid(address addr, uint256 tid) external {
        mustManager(managerName);
        nodes[addr].maxFinishedTid = tid;
    }

    function getStatus(address addr) external view returns (uint256) {
        return nodes[addr].status;
    }

    function setStatus(address addr, uint256 status) external {
        mustManager(managerName);
        nodes[addr].status = status;
    }

    function availableSpace(address addr) external view returns (uint256) {
        return nodes[addr].storageSpace.availableSpace();
    }

    function getStorageTotal(address addr) external view returns (uint256) {
        return nodes[addr].storageSpace.total;
    }

    function setStorageTotal(address addr, uint256 value) external {
        mustManager(managerName);
        nodes[addr].storageSpace.total = value;
    }

    function getStorageUsed(address addr) external view returns (uint256) {
        return nodes[addr].storageSpace.used;
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

    function getAddFileFailedCount(string calldata cid) external view returns (uint256) {
        return cid2addFileFailedCount[cid];
    }

    function resetAddFileFailedCount(string calldata cid) external {
        mustManager(managerName);
        cid2addFileFailedCount[cid] = 0;
    }

    function upAddFileFailedCount(string calldata cid) external returns (uint256) {
        mustManager(managerName);
        cid2addFileFailedCount[cid] = cid2addFileFailedCount[cid].add(1);
        return cid2addFileFailedCount[cid];
    }

    function getTotalNodeNumber() external view returns (uint256) {
        return nodeAddrs.length();
    }

    function getTotalOnlineNodeNumber() external view returns (uint256) {
        return onlineNodeAddrs.length();
    }
}
