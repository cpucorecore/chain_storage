pragma solidity ^0.5.2;
pragma experimental ABIEncoderV2;

import "./storages/ExternalStorage.sol";
import "./interfaces/storages/IUserStorage.sol";
import "./lib/EnumerableSet.sol";

contract UserStorage is ExternalStorage, IUserStorage {
    using EnumerableSet for EnumerableSet.Bytes32Set;

    mapping(address=>UserItem) private users;
    mapping(address=>mapping(bytes32=>FileItem)) files;
    uint256 private toatalUserNumber;

    constructor(address _manager) public ExternalStorage(_manager) {}

    function exist(address addr) public returns (bool) {
        return users[addr].exist;
    }

    function newUser(address addr, uint256 storageTotal, string calldata ext) external {
        require(!exist(addr), contractName.concat(": user exist"));

        EnumerableSet.Bytes32Set memory cidHashes;
        users[addr] = UserItem(StorageInfo(storageTotal, 0), cidHashes, 0, ext, true);

        toatalUserNumber = toatalUserNumber.add(1);
    }

    function deleteUser(address addr) external {
        require(exist(addr), contractName.concat(": user not exist"));
        delete users[addr];

        toatalUserNumber = toatalUserNumber.sub(1);
    }

    function getExt(address addr) external view returns (string memory) {
        return users[addr].ext;
    }

    function setExt(address addr, string calldata ext) external {
        users[addr].ext = ext;
    }

    function getStorageFree(address addr) external view returns (uint256) {
        if(users[addr].storageInfo.used > users[addr].storageInfo.total) return 0;
        return users[addr].storageInfo.total.sub(users[addr].storageInfo.used);
    }

    function getStorageTotal(address addr) external view returns (uint256) {
        return users[addr].storageInfo.total;
    }

    function setStorageTotal(address addr, uint256 size) external {
        users[addr].storageInfo.total = size;
    }

    function getStorageUsed(address addr) external view returns (uint256) {
        return users[addr].storageInfo.used;
    }

    function setStorageUsed(address addr, uint256 size) external {
        users[addr].storageInfo.used = size;
    }

    function addFile(address addr, string calldata cid, uint256 duration, string calldata ext, uint256 createTime) external {
        bytes32 cidHash = keccak256(bytes(cid));
        files[addr][cidHash] = FileItem(cid, createTime, duration, ext, true);
        users[addr].cidHashes.add(cidHash);
    }

    function deleteFile(address addr, string calldata cid) external {
        bytes32 cidHash = keccak256(bytes(cid));
        users[addr].cidHashes.remove(cidHash);
        delete files[addr][cidHash];
    }

    function fileExist(address addr, string calldata cid) external view returns(bool) {
        bytes32 cidHash = keccak256(bytes(cid));
        return users[addr].cidHashes.contains(cidHash);
    }

    function getFileExt(address addr, string calldata cid) external view returns (string memory) {
        bytes32 cidHash = keccak256(bytes(cid));
        return files[addr][cidHash].ext;
    }

    function setFileExt(address addr, string calldata cid, string calldata ext) external {
        bytes32 cidHash = keccak256(bytes(cid));
        files[addr][cidHash].ext = ext;
    }

    function getFileDuration(address addr, string calldata cid) external view returns (uint256) {
        bytes32 cidHash = keccak256(bytes(cid));
        return files[addr][cidHash].duration;
    }

    function setFileDuration(address addr, string calldata cid, uint256 duration) external {
        bytes32 cidHash = keccak256(bytes(cid));
        files[addr][cidHash].duration = duration;
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

    function getFileItem(address addr, string calldata cid) external view returns (FileItem memory) {
        bytes32 cidHash = keccak256(bytes(cid));
        return files[addr][cidHash];
    }

    function getInvalidAddFileCount(address addr) external view returns (uint256) {
        return users[addr].invalidAddFileCount;
    }

    function setInvalidAddFileCount(address addr, uint256 count) external {
        users[addr].invalidAddFileCount = count;
    }

    function getTotalUserNumber() external view returns (uint256) {
        return toatalUserNumber;
    }
}
