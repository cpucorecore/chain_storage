pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import "./ExternalStorage.sol";
import "../interfaces/storages/IUserStorage.sol";

contract UserStorage is ExternalStorage, IUserStorage {
    mapping(uint256=>string) fid2cid;
    mapping(address=>mapping(string=>FileInfo)) fileInfos;
    mapping(address=>UserItem) private users;

    function newUser(address addr, uint256 space, string calldata ext) external {
        EnumerableSet.UintSet memory fids;
        users[addr] = UserItem(0, space, fids, ext, true);
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

    function addFile(address addr, string calldata cid, uint256 fid, uint256 duration, string calldata ext) external {
        fid2cid[fid] = cid;
        fileInfos[addr][cid] = FileInfo(fid, duration, ext, true);
        users[addr].fids.add(fid);
    }

    function deleteFile(address addr, string memory cid) public {
        users[addr].fids.remove(fileInfos[addr][cid].fid);
        delete fileInfos[addr][cid];
    }

    function fileExist(address addr, string calldata cid) external view returns(bool) {
        return fileInfos[addr][cid].exist;
    }

    function fileNumber(address addr) external view returns (uint256) {
        return users[addr].fids.length();
    }

    function cids(address addr, uint256 pageSize, uint256 pageNumber) public view returns (string[] memory, Paging.Page memory) {
        EnumerableSet.UintSet storage userFids = users[addr].fids;
        Paging.Page memory page = Paging.getPage(userFids.length(), pageSize, pageNumber);
        uint256 start = page.pageNumber.sub(1).mul(page.pageSize);
        string[] memory result = new string[](page.pageRecords);
        for(uint256 i=0; i<page.pageRecords; i++) {
            result[i] = fid2cid[userFids.at(start+i)];
        }
        return (result, page);
    }
}
