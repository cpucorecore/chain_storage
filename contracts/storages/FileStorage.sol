pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import './ExternalStorage.sol';
import '../interfaces/storages/IFileStorage.sol';

contract FileStorage is ExternalStorage, IFileStorage {
    uint256 private _fid;

    mapping(string=>uint256) private cid2fid;
    mapping(uint256=>FileItem) fid2file;
    mapping(uint256=>uint256) fid2duration;

    constructor(address _manager) public ExternalStorage(_manager) {
        _fid = 0;
    }

    function newFile(string calldata cid, uint256 size, address owner, uint256 duration) external returns (uint256) {
        EnumerableSet.AddressSet memory owners;
        EnumerableSet.AddressSet memory nodes;

        _fid = _fid.add(1);

        cid2fid[cid] = _fid;
        fid2file[_fid] = FileItem(cid, size, owners, nodes, true);
        fid2duration[_fid] = duration;
        addOwner(_fid, owner);

        return _fid;
    }

    function deleteFile(uint256 fid) public {
        delete cid2fid[fid2file[_fid].cid];
        delete fid2file[_fid];
        delete fid2duration[_fid];
    }

    function exist(uint256 fid) public view returns(bool) {
        return fid2file[_fid].exist;
    }

    function exist(string memory cid) public view returns (bool) {
        return fid2file[cid2fid[cid]].exist;
    }

    function size(uint256 fid) public view returns(uint256) {
        return fid2file[_fid].size;
    }

    function size(string calldata cid) external view returns (uint256) {
        return fid2file[cid2fid[cid]].size;
    }

    function cid(uint256 fid) external view returns (string memory) {
        return fid2file[_fid].cid;
    }

    function fid(string calldata cid) external view returns (uint256) {
        return cid2fid[cid];
    }

    function duration(uint256 fid) external view returns (uint256) {
        return fid2duration[_fid];
    }

    function ownerExist(uint256 fid, address owner) external view returns(bool) {
        return fid2file[_fid].owners.contains(owner);
    }

    function addOwner(uint256 fid, address owner) public {
        fid2file[_fid].owners.add(owner);
    }

    function delOwner(uint256 fid, address owner) public {
        fid2file[_fid].owners.remove(owner);
    }

    function owners(uint256 fid, uint256 pageSize, uint256 pageNumber) external view returns(address[] memory, Paging.Page memory) {
        EnumerableSet.AddressSet storage fileOwners = fid2file[_fid].owners;
        Paging.Page memory page = Paging.getPage(fileOwners.length(), pageSize, pageNumber);

        uint256 start = page.pageNumber.sub(1).mul(page.pageSize);
        address[] memory result = new address[](page.pageRecords);
        for(uint256 i=0; i<page.pageRecords; i++) {
            result[i] = fileOwners.at(start+i);
        }

        return (result, page);
    }

    function owners(uint256 fid) external view returns (address[] memory) {
        EnumerableSet.AddressSet storage fileOwners = fid2file[_fid].owners;
        uint256 count = fileOwners.length();
        address[] memory result = new address[](count);
        for(uint256 i=0; i<count; i++) {
            result[i] = fileOwners.at(i);
        }
        return result;
    }

    function nodeExist(uint256 fid, address nodeAddr) external view returns(bool) {
        return fid2file[_fid].nodes.contains(nodeAddr);
    }

    function addNode(uint256 fid, address nodeAddr) public {
        fid2file[_fid].nodes.add(nodeAddr);
    }

    function delNode(uint256 fid, address nodeAddr) public {
        fid2file[_fid].nodes.remove(nodeAddr);
    }

    function nodes(uint256 fid, uint256 pageSize, uint256 pageNumber) external view returns(address[] memory, Paging.Page memory) {
        EnumerableSet.AddressSet storage fileNodes = fid2file[_fid].nodes;
        Paging.Page memory page = Paging.getPage(fileNodes.length(), pageSize, pageNumber);

        uint256 start = page.pageNumber.sub(1).mul(page.pageSize);
        address[] memory result = new address[](page.pageRecords);
        for(uint256 i=0; i<page.pageRecords; i++) {
            result[i] = fileNodes.at(start+i);
        }

        return (result, page);
    }

    function nodes(uint256 fid) external view returns (address[] memory) {
        EnumerableSet.AddressSet storage fileNodes = fid2file[_fid].nodes;
        uint256 count = fileNodes.length();
        address[] memory result = new address[](count);
        for(uint256 i=0; i<count; i++) {
            result[i] = fileNodes.at(i);
        }
        return result;
    }
}
