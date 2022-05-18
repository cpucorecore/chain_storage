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
    EnumerableSet.AddressSet private nodeAddresses;
    EnumerableSet.AddressSet private onlineNodeAddresses;
    mapping(string=>uint256) private cid2addFileFailedCount;

    constructor(address _manager) public ExternalStorage(_manager) {}

    function exist(address nodeAddress) public view returns (bool) {
        return DefaultStatus != nodes[nodeAddress].status;
    }

    function newNode(address nodeAddress, uint256 storageTotal, string calldata ext) external {
        mustManager(managerName);
        nodes[nodeAddress] = NodeItem(NodeRegistered, StorageSpaceManager.StorageSpace(0, storageTotal), 0, ext);
        nodeAddresses.add(nodeAddress);
    }

    function deleteNode(address nodeAddress) external {
        mustManager(managerName);
        delete nodes[nodeAddress];
        nodeAddresses.remove(nodeAddress);
        onlineNodeAddresses.remove(nodeAddress);
    }

    function useStorage(address nodeAddress, uint256 size) external {
        nodes[nodeAddress].storageSpace.useSpace(size);
    }

    function freeStorage(address nodeAddress, uint256 size) external {
        nodes[nodeAddress].storageSpace.unUseSpace(size);
    }

    function isNodeOnline(address nodeAddress) external view returns (bool) {
        return onlineNodeAddresses.contains(nodeAddress);
    }

    function addOnlineNode(address nodeAddress) external {
        mustManager(managerName);
        onlineNodeAddresses.add(nodeAddress);
    }

    function deleteOnlineNode(address nodeAddress) external {
        mustManager(managerName);
        onlineNodeAddresses.remove(nodeAddress);
    }

    function getStorageSpace(address nodeAddress) public view returns (uint256, uint256) {
        return (nodes[nodeAddress].storageSpace.used, nodes[nodeAddress].storageSpace.total);
    }

    function getMaxFinishedTid(address nodeAddress) external view returns (uint256) {
        return nodes[nodeAddress].maxFinishedTid;
    }

    function setMaxFinishedTid(address nodeAddress, uint256 tid) external {
        mustManager(managerName);
        nodes[nodeAddress].maxFinishedTid = tid;
    }

    function getStatus(address nodeAddress) external view returns (uint256) {
        return nodes[nodeAddress].status;
    }

    function setStatus(address nodeAddress, uint256 status) external {
        mustManager(managerName);
        nodes[nodeAddress].status = status;
    }

    function availableSpace(address nodeAddress) external view returns (uint256) {
        return nodes[nodeAddress].storageSpace.availableSpace();
    }

    function getStorageTotal(address nodeAddress) external view returns (uint256) {
        return nodes[nodeAddress].storageSpace.total;
    }

    function setStorageTotal(address nodeAddress, uint256 value) external {
        mustManager(managerName);
        nodes[nodeAddress].storageSpace.total = value;
    }

    function getStorageUsed(address nodeAddress) external view returns (uint256) {
        return nodes[nodeAddress].storageSpace.used;
    }

    function getExt(address nodeAddress) external view returns (string memory) {
        return nodes[nodeAddress].ext;
    }

    function setExt(address nodeAddress, string calldata ext) external {
        mustManager(managerName);
        nodes[nodeAddress].ext = ext;
    }

    function getAllNodeAddresses() public view returns (address[] memory) {
        return nodeAddresses.values();
    }

    function getAllNodeAddresses(uint256 pageSize, uint256 pageNumber) public view returns (address[] memory, bool) {
        Paging.Page memory page = Paging.getPage(nodeAddresses.length(), pageSize, pageNumber);
        uint256 start = page.pageNumber.sub(1).mul(page.pageSize);
        address[] memory result = new address[](page.pageRecords);
        for(uint256 i=0; i<page.pageRecords; i++) {
            result[i] = nodeAddresses.at(start+i);
        }
        return (result, page.pageNumber == page.totalPages);
    }

    function getAllOnlineNodeAddresses() public view returns (address[] memory) {
        return onlineNodeAddresses.values();
    }

    function getAllOnlineNodeAddresses(uint256 pageSize, uint256 pageNumber) public view returns (address[] memory, bool) {
        Paging.Page memory page = Paging.getPage(onlineNodeAddresses.length(), pageSize, pageNumber);
        uint256 start = page.pageNumber.sub(1).mul(page.pageSize);
        address[] memory result = new address[](page.pageRecords);
        for(uint256 i=0; i<page.pageRecords; i++) {
            result[i] = onlineNodeAddresses.at(start+i);
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
        return nodeAddresses.length();
    }

    function getTotalOnlineNodeNumber() external view returns (uint256) {
        return onlineNodeAddresses.length();
    }
}
