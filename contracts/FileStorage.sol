pragma solidity ^0.5.2;
pragma experimental ABIEncoderV2;

import "./storages/ExternalStorage.sol";
import "./interfaces/storages/IFileStorage.sol";
import "./lib/EnumerableSet.sol";
import "./lib/Paging.sol";

contract FileStorage is ExternalStorage, IFileStorage {
    using EnumerableSet for EnumerableSet.AddressSet;

    struct FileItem {
        uint256 size;
        bool exist;
        EnumerableSet.AddressSet owners;
        EnumerableSet.AddressSet nodes;
    }

    mapping(string=>FileItem) private cid2fileItem;
    uint256 private totalSize; // TODO: measure accurate
    uint256 private totalFileNumber;  // TODO: measure accurate

    constructor(address _manager) public ExternalStorage(_manager) {}

    function exist(string memory cid) public view returns (bool) {
        return cid2fileItem[cid].exist;
    }

    function newFile(string calldata cid, uint256 size) external {
        mustManager(managerName);

        EnumerableSet.AddressSet memory owners;
        EnumerableSet.AddressSet memory nodes;
        cid2fileItem[cid] = FileItem(size, true, owners, nodes);

        totalSize = totalSize.add(size);
        totalFileNumber = totalFileNumber.add(1);
    }

    function deleteFile(string calldata cid) external {
        mustManager(managerName);

        totalSize = totalSize.sub(cid2fileItem[cid].size);
        totalFileNumber = totalFileNumber.sub(1);

        delete cid2fileItem[cid];
    }

    function getSize(string calldata cid) external view returns (uint256) {
        return cid2fileItem[cid].size;
    }

    function setSize(string calldata cid, uint256 size) external {
        mustManager(managerName);
        cid2fileItem[cid].size = size;
    }

    function ownerExist(string calldata cid, address owner) external view returns (bool) {
        return cid2fileItem[cid].owners.contains(owner);
    }

    function ownerEmpty(string calldata cid) external view returns (bool) {
        return 0 == cid2fileItem[cid].owners.length();
    }

    function addOwner(string calldata cid, address owner) external {
        mustManager(managerName);
        cid2fileItem[cid].owners.add(owner);
    }

    function deleteOwner(string calldata cid, address owner) external {
        mustManager(managerName);
        cid2fileItem[cid].owners.remove(owner);
    }

    function getOwners(string calldata cid) external view returns (address[] memory) {
        EnumerableSet.AddressSet storage owners = cid2fileItem[cid].owners;
        uint256 count = owners.length();
        address[] memory result = new address[](count);
        for(uint256 i=0; i<count; i++) {
            result[i] = owners.at(i);
        }
        return result;
    }

    function getOwners(string calldata cid, uint256 pageSize, uint256 pageNumber) external view returns (address[] memory, bool) {
        EnumerableSet.AddressSet storage owners = cid2fileItem[cid].owners;
        Paging.Page memory page = Paging.getPage(owners.length(), pageSize, pageNumber);
        uint256 start = page.pageNumber.sub(1).mul(page.pageSize);
        address[] memory result = new address[](page.pageRecords);
        for(uint256 i=0; i<page.pageRecords; i++) {
            result[i] = owners.at(start+i);
        }
        return (result, page.pageNumber == page.totalPages);
    }

    function nodeExist(string calldata cid, address node) external view returns (bool) {
        return cid2fileItem[cid].nodes.contains(node);
    }

    function nodeEmpty(string calldata cid) external view returns (bool) {
        return 0 == cid2fileItem[cid].nodes.length();
    }

    function addNode(string calldata cid, address node) external {
        mustManager(managerName);
        cid2fileItem[cid].nodes.add(node);
    }

    function deleteNode(string calldata cid, address node) external {
        mustManager(managerName);
        cid2fileItem[cid].nodes.remove(node);
    }

    function getNodes(string calldata cid) external view returns (address[] memory) {
        EnumerableSet.AddressSet storage nodes = cid2fileItem[cid].nodes;
        uint256 count = nodes.length();
        address[] memory result = new address[](count);
        for(uint256 i=0; i<count; i++) {
            result[i] = nodes.at(i);
        }
        return result;
    }

    function getNodes(string calldata cid, uint256 pageSize, uint256 pageNumber) external view returns (address[] memory, bool) {
        EnumerableSet.AddressSet storage nodes = cid2fileItem[cid].nodes;
        Paging.Page memory page = Paging.getPage(nodes.length(), pageSize, pageNumber);
        uint256 start = page.pageNumber.sub(1).mul(page.pageSize);
        address[] memory result = new address[](page.pageRecords);
        for(uint256 i=0; i<page.pageRecords; i++) {
            result[i] = nodes.at(start+i);
        }
        return (result, page.totalPages == page.pageNumber);
    }

    function getTotalSize() external view returns (uint256) {
        return totalSize;
    }

    function getTotalFileNumber() external view returns (uint256) {
        return totalFileNumber;
    }
}
