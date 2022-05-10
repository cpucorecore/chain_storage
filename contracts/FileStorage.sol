pragma solidity ^0.5.2;
pragma experimental ABIEncoderV2;

import "./storages/ExternalStorage.sol";
import './interfaces/storages/IFileStorage.sol';
import "./lib/EnumerableSet.sol";
import "./lib/Paging.sol";

contract FileStorage is ExternalStorage, IFileStorage {
    using EnumerableSet for EnumerableSet.AddressSet;

    struct FileItem {
        string cid;
        uint256 size;
        EnumerableSet.AddressSet owners;
        EnumerableSet.AddressSet nodes;
        bool exist;
    }

    mapping(bytes32=>FileItem) private cidHash2fileItem;
    uint256 private totalSize; // TODO: measure accurate
    uint256 private toatalFileNumber;  // TODO: measure accurate

    constructor(address _manager) public ExternalStorage(_manager) {}

    function exist(string memory cid) public view returns (bool) {
        bytes32 cidHash = keccak256(bytes(cid));
        return cidHash2fileItem[cidHash].exist;
    }

    function newFile(string calldata cid, uint256 size) external onlyManager(managerName) {
        bytes32 cidHash = keccak256(bytes(cid));
        require(!cidHash2fileItem[cidHash].exist, contractName.concat(": file exist"));

        EnumerableSet.AddressSet memory owners;
        EnumerableSet.AddressSet memory nodes;
        cidHash2fileItem[cidHash] = FileItem(cid, size, owners, nodes, true);

        totalSize = totalSize.add(size);
        toatalFileNumber = toatalFileNumber.add(1);
    }

    function deleteFile(string calldata cid) external onlyManager(managerName) {
        bytes32 cidHash = keccak256(bytes(cid));
        require(cidHash2fileItem[cidHash].exist, contractName.concat(": file not exist"));

        totalSize = totalSize.sub(cidHash2fileItem[cidHash].size);
        toatalFileNumber = toatalFileNumber.sub(1);

        delete cidHash2fileItem[cidHash];
    }

    function getSize(string calldata cid) external view returns (uint256) {
        bytes32 cidHash = keccak256(bytes(cid));
        return cidHash2fileItem[cidHash].size;
    }

    function setSize(string calldata cid, uint256 size) external onlyManager(managerName) {
        bytes32 cidHash = keccak256(bytes(cid));
        cidHash2fileItem[cidHash].size = size;
    }

    function ownerExist(string calldata cid, address owner) external view returns (bool) {
        bytes32 cidHash = keccak256(bytes(cid));
        return cidHash2fileItem[cidHash].owners.contains(owner);
    }

    function ownerEmpty(string calldata cid) external view returns (bool) {
        bytes32 cidHash = keccak256(bytes(cid));
        return 0 == cidHash2fileItem[cidHash].owners.length();
    }

    function addOwner(string calldata cid, address owner) external onlyManager(managerName) {
        bytes32 cidHash = keccak256(bytes(cid));
        cidHash2fileItem[cidHash].owners.add(owner);
    }

    function deleteOwner(string calldata cid, address owner) external onlyManager(managerName) {
        bytes32 cidHash = keccak256(bytes(cid));
        cidHash2fileItem[cidHash].owners.remove(owner);
    }

    function getOwners(string calldata cid) external view returns (address[] memory) {
        bytes32 cidHash = keccak256(bytes(cid));
        EnumerableSet.AddressSet storage owners = cidHash2fileItem[cidHash].owners;
        uint256 count = owners.length();
        address[] memory result = new address[](count);
        for(uint256 i=0; i<count; i++) {
            result[i] = owners.at(i);
        }
        return result;
    }

    function getOwners(string calldata cid, uint256 pageSize, uint256 pageNumber) external view returns (address[] memory, bool) {
        bytes32 cidHash = keccak256(bytes(cid));
        EnumerableSet.AddressSet storage owners = cidHash2fileItem[cidHash].owners;
        Paging.Page memory page = Paging.getPage(owners.length(), pageSize, pageNumber);
        uint256 start = page.pageNumber.sub(1).mul(page.pageSize);
        address[] memory result = new address[](page.pageRecords);
        for(uint256 i=0; i<page.pageRecords; i++) {
            result[i] = owners.at(start+i);
        }
        return (result, page.pageNumber == page.totalPages);
    }

    function nodeExist(string calldata cid, address node) external view returns (bool) {
        bytes32 cidHash = keccak256(bytes(cid));
        return cidHash2fileItem[cidHash].nodes.contains(node);
    }

    function nodeEmpty(string calldata cid) external view returns (bool) {
        bytes32 cidHash = keccak256(bytes(cid));
        return 0 == cidHash2fileItem[cidHash].nodes.length();
    }

    function addNode(string calldata cid, address node) external onlyManager(managerName) {
        bytes32 cidHash = keccak256(bytes(cid));
        cidHash2fileItem[cidHash].nodes.add(node);
    }

    function deleteNode(string calldata cid, address node) external onlyManager(managerName) {
        bytes32 cidHash = keccak256(bytes(cid));
        cidHash2fileItem[cidHash].nodes.remove(node);
    }

    function getNodes(string calldata cid) external view returns (address[] memory) {
        bytes32 cidHash = keccak256(bytes(cid));
        EnumerableSet.AddressSet storage nodes = cidHash2fileItem[cidHash].nodes;
        uint256 count = nodes.length();
        address[] memory result = new address[](count);
        for(uint256 i=0; i<count; i++) {
            result[i] = nodes.at(i);
        }
        return result;
    }

    function getNodes(string calldata cid, uint256 pageSize, uint256 pageNumber) external view returns (address[] memory, bool) {
        bytes32 cidHash = keccak256(bytes(cid));
        EnumerableSet.AddressSet storage nodes = cidHash2fileItem[cidHash].nodes;
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
        return toatalFileNumber;
    }
}
