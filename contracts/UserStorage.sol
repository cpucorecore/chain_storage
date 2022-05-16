pragma solidity ^0.5.2;
pragma experimental ABIEncoderV2;

import "./storages/ExternalStorage.sol";
import "./interfaces/storages/IUserStorage.sol";
import "./lib/EnumerableSet.sol";
import "./lib/Paging.sol";
import "./lib/StorageSpaceManager.sol";

contract UserStorage is ExternalStorage, IUserStorage {
    using StorageSpaceManager for StorageSpaceManager.StorageSpace;
    using EnumerableSet for EnumerableSet.Bytes32Set;

    struct FileItem {
        string cid;
        uint256 createTime;
        uint256 duration;
        string ext;
    }

    struct UserItem {
        StorageSpaceManager.StorageSpace storageSpace;
        EnumerableSet.Bytes32Set cidHashes;
        uint256 invalidAddFileCount;
        string ext;
    }

    mapping(address=>UserItem) private users;
    mapping(address=>mapping(bytes32=>FileItem)) files;
    uint256 private totalUserNumber;

    constructor(address _manager) public ExternalStorage(_manager) {}

    function newUser(address addr, uint256 storageTotal, string calldata ext) external {
        mustManager(managerName);
        EnumerableSet.Bytes32Set memory cidHashes;
        users[addr] = UserItem(StorageSpaceManager.StorageSpace(0, storageTotal), cidHashes, 0, ext);
        totalUserNumber = totalUserNumber.add(1);
    }

    function deleteUser(address addr) external {
        mustManager(managerName);
        delete users[addr];
        totalUserNumber = totalUserNumber.sub(1);
    }

    function setExt(address addr, string calldata ext) external {
        mustManager(managerName);
        users[addr].ext = ext;
    }

    function setStorageTotal(address addr, uint256 size) external {
        mustManager(managerName);
        users[addr].storageSpace.total = size;
    }

    function useStorage(address addr, uint256 size) external {
        mustManager(managerName);
        users[addr].storageSpace.useSpace(size);
    }

    function freeStorage(address addr, uint256 size) external {
        mustManager(managerName);
        users[addr].storageSpace.unUseSpace(size);
    }

    function exist(address addr) public view returns (bool) {
        return users[addr].storageSpace.total > 0;
    }

    function getExt(address addr) external view returns (string memory) {
        return users[addr].ext;
    }

    function availableSpace(address addr) external view returns (uint256) {
        return users[addr].storageSpace.availableSpace();
    }

    function getStorageTotal(address addr) external view returns (uint256) {
        return users[addr].storageSpace.total;
    }

    function getStorageUsed(address addr) external view returns (uint256) {
        return users[addr].storageSpace.used;
    }

    function addFile(address addr, string calldata cid, uint256 duration, string calldata ext, uint256 createTime) external {
        mustManager(managerName);
        bytes32 cidHash = keccak256(bytes(cid));
        files[addr][cidHash] = FileItem(cid, createTime, duration, ext);
        users[addr].cidHashes.add(cidHash);
    }

    function deleteFile(address addr, string calldata cid) external {
        mustManager(managerName);
        bytes32 cidHash = keccak256(bytes(cid));
        users[addr].cidHashes.remove(cidHash);
        delete files[addr][cidHash];
    }

    function setFileExt(address addr, string calldata cid, string calldata ext) external {
        mustManager(managerName);
        bytes32 cidHash = keccak256(bytes(cid));
        files[addr][cidHash].ext = ext;
    }

    function setFileDuration(address addr, string calldata cid, uint256 duration) external {
        mustManager(managerName);
        bytes32 cidHash = keccak256(bytes(cid));
        files[addr][cidHash].duration = duration;
    }

    function setInvalidAddFileCount(address addr, uint256 count) external {
        mustManager(managerName);
        users[addr].invalidAddFileCount = count;
    }

    function fileExist(address addr, string calldata cid) external view returns(bool) {
        bytes32 cidHash = keccak256(bytes(cid));
        return users[addr].cidHashes.contains(cidHash);
    }

    function getFileExt(address addr, string calldata cid) external view returns (string memory) {
        bytes32 cidHash = keccak256(bytes(cid));
        return files[addr][cidHash].ext;
    }

    function getFileDuration(address addr, string calldata cid) external view returns (uint256) {
        bytes32 cidHash = keccak256(bytes(cid));
        return files[addr][cidHash].duration;
    }

    function getFileNumber(address addr) external view returns (uint256) {
        return users[addr].cidHashes.length();
    }

    function getCids(address addr, uint256 pageSize, uint256 pageNumber) public view returns (string[] memory, bool) {
        EnumerableSet.Bytes32Set storage userCidHashes = users[addr].cidHashes;
        Paging.Page memory page = Paging.getPage(userCidHashes.length(), pageSize, pageNumber);
        uint256 start = page.pageNumber.sub(1).mul(page.pageSize);
        string[] memory result = new string[](page.pageRecords);
        for(uint256 i=0; i<page.pageRecords; i++) {
            result[i] = files[addr][userCidHashes.at(start+i)].cid;
        }
        return (result, page.totalPages == page.pageNumber);
    }

    function getFileItem(address addr, string calldata cid) external view returns (string memory, uint256, uint256, string memory) {
        bytes32 cidHash = keccak256(bytes(cid));
        FileItem storage file = files[addr][cidHash];
        return (file.cid, file.createTime, file.duration, file.ext);
    }

    function getInvalidAddFileCount(address addr) external view returns (uint256) {
        return users[addr].invalidAddFileCount;
    }

    function getTotalUserNumber() external view returns (uint256) {
        return totalUserNumber;
    }
}
