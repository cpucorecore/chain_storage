pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import "./ExternalStorage.sol";
import "../interfaces/storages/IUserStorage.sol";

contract UserStorage is ExternalStorage, IUserStorage {
    using EnumerableSet for EnumerableSet.Bytes32Set;

    struct FileItem {
        uint256 duration;
        string ext;
        bool exist;
    }

    struct UserItem {
        uint256 used;
        uint256 space;
        EnumerableSet.Bytes32Set cidHashs;
        string ext;
        bool exist;
    }

    mapping(address=>UserItem) private users;
    mapping(address=>mapping(bytes32=>FileItem)) files;

    function newUser(address addr, uint256 space, string calldata ext) external {
        EnumerableSet.Bytes32Set memory cidHashs;
        users[addr] = UserItem(0, space, cidHashs, ext, true);
    }

    function deleteUser(address addr) public {
        delete users[addr];
    }

    function exist(address addr) public returns (bool) {
        return users[addr].exist;
    }

    function space(address addr) external view returns (uint256) {
        return users[addr].space;
    }

    function setSpace(address addr, uint256 space) external {
        users[addr].space = space;
    }

    function used(address addr) external view returns (uint256) {
        return users[addr].used;
    }

    function spaceEnough(address addr, uint256 space) public view returns (bool) {
        return users[addr].used.add(space) <= users[addr].space;
    }

    function useSpace(address addr, uint256 space) public {
        users[addr].used = users[addr].used.add(space);
    }

    function freeSpace(address addr, uint256 space) external {
        require(space <= users[addr].used, contractName.concat(": wrong space"));
        users[addr].used = users[addr].used.sub(space);
    }

    function storageInfo(address addr) external view returns(uint256, uint256) {
        return (users[addr].used, users[addr].space);
    }

    function addFile(address addr, string calldata cid, uint256 duration, string calldata ext) external {
        bytes32 cidHash = keccak256(bytes(cid));
        files[addr][cidHash] = FileItem(duration, ext, true);
        users[addr].cidHashs.add(cidHash);
    }

    function deleteFile(address addr, string calldata cid) external {
        bytes32 cidHash = keccak256(bytes(cid));
        users[addr].cidHashs.remove(cidHash);
        delete files[addr][cidHash];
    }

    function fileExist(address addr, string calldata cid) external view returns(bool) {
        bytes32 cidHash = keccak256(bytes(cid));
        return users[addr].cidHashs.contains(cidHash);
    }

    function fileNumber(address addr) external view returns (uint256) {
        return users[addr].cidHashs.length();
    }

    function cids(address addr, uint256 pageSize, uint256 pageNumber) public view returns (string[] memory, Paging.Page memory) {
//        EnumerableSet.UintSet storage userFids = users[addr].fids;
//        Paging.Page memory page = Paging.getPage(userFids.length(), pageSize, pageNumber);
//        uint256 start = page.pageNumber.sub(1).mul(page.pageSize);
//        string[] memory result = new string[](page.pageRecords);
//        for(uint256 i=0; i<page.pageRecords; i++) {
//            result[i] = fid2cid[userFids.at(start+i)];
//        }
//        return (result, page);
    }
}
