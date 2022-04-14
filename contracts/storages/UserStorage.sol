pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import "./ExternalStorage.sol";
import "../interfaces/storages/IUserStorage.sol";

contract UserStorage is ExternalStorage, IUserStorage {
    mapping(address=>UserItem) private users;
    mapping(bytes32=>FileInfo) hash2FileInfo;

    function newUser(address addr, uint256 space) public {
        EnumerableSet.Bytes32Set memory cidHashs;
        users[addr] = UserItem(true, 0, space, cidHashs);
    }

    function deleteUser(address addr) public {
        delete users[addr];
    }

    function exist(address addr) public returns(bool) {
        return users[addr].exist;
    }

    function storageSpace(address addr) public returns(uint256) {
        return users[addr].space;
    }

    function storageSpace(address addr, uint256 storageSpace) public {
        users[addr].space = storageSpace;
    }

    function storageUsed(address addr) public returns(uint256) {
        return users[addr].used;
    }

    function storageUsed(address addr, uint256 storageUsed) public {
        users[addr].used = storageUsed;
    }

    function freeStorageUsed(address addr, uint256 space) public {
        users[addr].used = users[addr].used.sub(space);
    }

    function useStorage(address addr, uint256 space) public {
        users[addr].used = users[addr].used.add(space);
    }

    function storageInfo(address addr) public returns(uint256, uint256) {
        return (users[addr].used, users[addr].space);
    }

    function cids(address addr) public returns(string[] memory) {
        // TODO page query
        EnumerableSet.Bytes32Set storage cidHashs = users[addr].cidHashs;
        uint256 count = cidHashs.length();
        string[] memory result = new string[](count);
        for(uint i=0; i<count; i++) {
            result[i] = hash2FileInfo[cidHashs.at(i)].cid;
        }

        return result;
    }

    function fileExist(address addr, string memory cid) public returns(bool) {
        bytes32 hash = keccak256(bytes(cid));
        return users[addr].cidHashs.contains(hash);
    }

    function addFile(address addr, string memory cid, uint256 size, uint256 duration, string memory ext) public {
        bytes32 hash = keccak256(bytes(cid));
        hash2FileInfo[hash] = FileInfo(true, size, duration, cid, ext);
        users[addr].cidHashs.add(hash);
    }

    function deleteFile(address addr, string memory cid) public {
        bytes32 hash = keccak256(bytes(cid));
        users[addr].cidHashs.remove(hash);
    }

    function fileCount(address addr) public returns(uint256) {
        return users[addr].cidHashs.length();
    }
}
