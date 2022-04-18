pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import "./ExternalStorage.sol";
import "../interfaces/storages/IUserStorage.sol";

contract UserStorage is ExternalStorage, IUserStorage {
    mapping(address=>UserItem) private users;
    mapping(bytes32=>FileInfo) hash2FileInfo;

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
