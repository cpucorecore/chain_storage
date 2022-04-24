pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import './ExternalStorage.sol';
import '../interfaces/storages/IFileStorage.sol';
import "../lib/EnumerableSet.sol";

contract FileStorage is ExternalStorage, IFileStorage {
    using EnumerableSet for EnumerableSet.AddressSet;

    enum Status {
        New,
        Adding,
        PartialAdded,
        Added,
        PartialDeleted,
        Deleted
    }

    struct FileItem {
        Status status;
        uint256 size;
        EnumerableSet.AddressSet owners;
        EnumerableSet.AddressSet nodes;
        bool exist;
    }

    mapping(string=>FileItem) cid2fileItem;

    constructor(address _manager) public ExternalStorage(_manager) {}


    function newFile(string calldata cid, uint256 size) external {
        EnumerableSet.AddressSet memory owners;
        EnumerableSet.AddressSet memory nodes;
        cid2fileItem[cid] = FileItem(Status.New, size, owners, nodes, true);
    }

    function deleteFile(string calldata cid) external {
        delete cid2fileItem[cid];
    }

    function exist(string memory cid) public view returns (bool) {
        return cid2fileItem[cid].exist;
    }

    function size(string calldata cid) external view returns (uint256) {
        return cid2fileItem[cid].size;
    }

    function ownerExist(string calldata cid, address owner) external view returns (bool) {
        return exist(cid) && cid2fileItem[cid].owners.contains(owner);
    }

    function ownerEmpty(string calldata cid) external view returns (bool) {
        return 0 == cid2fileItem[cid].owners.length();
    }

    function addOwner(string calldata cid, address owner) external {
        cid2fileItem[cid].owners.add(owner);
    }

    function delOwner(string calldata cid, address owner) external {
        cid2fileItem[cid].owners.remove(owner);
    }

    function owners(string calldata cid, uint256 pageSize, uint256 pageNumber) external view returns (address[] memory, Paging.Page memory) {
        EnumerableSet.AddressSet storage _owners = cid2fileItem[cid].owners;
        Paging.Page memory page = Paging.getPage(_owners.length(), pageSize, pageNumber);
        uint256 start = page.pageNumber.sub(1).mul(page.pageSize);
        address[] memory result = new address[](page.pageRecords);
        for(uint256 i=0; i<page.pageRecords; i++) {
            result[i] = _owners.at(start+i);
        }
        return (result, page);
    }

    function owners(string calldata cid) external view returns (address[] memory) {
        EnumerableSet.AddressSet storage _owners = cid2fileItem[cid].owners;
        uint256 count = _owners.length();
        address[] memory result = new address[](count);
        for(uint256 i=0; i<count; i++) {
            result[i] = _owners.at(i);
        }
        return result;
    }

    function nodeExist(string calldata cid, address node) external view returns (bool) {
        return cid2fileItem[cid].nodes.contains(node);
    }

    function nodeEmpty(string calldata cid) external view returns (bool) {
        return 0 == cid2fileItem[cid].nodes.length();
    }

    function addNode(string calldata cid, address node) external {
        cid2fileItem[cid].nodes.add(node);
    }

    function delNode(string calldata cid, address node) external {
        cid2fileItem[cid].nodes.remove(node);
    }

    function nodes(string calldata cid, uint256 pageSize, uint256 pageNumber) external view returns (address[] memory, Paging.Page memory) {
        EnumerableSet.AddressSet storage _nodes = cid2fileItem[cid].nodes;
        Paging.Page memory page = Paging.getPage(_nodes.length(), pageSize, pageNumber);
        uint256 start = page.pageNumber.sub(1).mul(page.pageSize);
        address[] memory result = new address[](page.pageRecords);
        for(uint256 i=0; i<page.pageRecords; i++) {
            result[i] = _nodes.at(start+i);
        }

        return (result, page);
    }

    function nodes(string calldata cid) external view returns (address[] memory) {
        EnumerableSet.AddressSet storage _nodes = cid2fileItem[cid].nodes;
        uint256 count = _nodes.length();
        address[] memory result = new address[](count);
        for(uint256 i=0; i<count; i++) {
            result[i] = _nodes.at(i);
        }
        return result;
    }
}
