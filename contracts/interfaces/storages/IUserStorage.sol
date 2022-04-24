pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import "./INodeStorage.sol";
import "../../lib/EnumerableSet.sol";

interface IUserStorage {
    using EnumerableSet for EnumerableSet.Bytes32Set;

    struct FileItem {
        string cid;
        uint256 createTime;
        uint256 duration;
        string ext;
        bool exist;
    }

    struct StorageInfo {
        uint256 total;
        uint256 used;
    }

    struct UserItem {
        StorageInfo storageInfo;
        EnumerableSet.Bytes32Set cidHashes;
        string ext;
        bool exist;
    }

    function newUser(address addr, uint256 storageTotal, string calldata ext) external;
    function deleteUser(address addr) external;
    function exist(address addr) external returns (bool);

    function getExt(address addr) external view returns (string memory);
    function setExt(address addr, string calldata ext) external;

    function getStorageFree(address addr) external view returns (uint256);
    function getStorageTotal(address addr) external view returns (uint256);
    function setStorageTotal(address addr, uint256 size) external;

    function getStorageUsed(address addr) external view returns (uint256);
    function setStorageUsed(address addr, uint256 size) external;

    function getStorageInfo(address addr) external view returns (StorageInfo memory);

    function addFile(address addr, string calldata cid, uint256 duration, string calldata ext, uint256 createTime) external;
    function deleteFile(address addr, string calldata cid) external;
    function fileExist(address addr, string calldata cid) external view returns (bool);

    function getFileExt(address addr, string calldata cid) external view returns (string memory);
    function setFileExt(address addr, string calldata cid, string calldata ext) external;

    function getFileDuration(address addr, string calldata cid) external view returns (uint256);
    function setFileDuration(address addr, string calldata cid, uint256 duration) external;

    function getFileNumber(address addr) external view returns (uint256);
    function getCids(address addr, uint256 pageSize, uint256 pageNumber) external view returns (string[] memory, Paging.Page memory);
    function getFileItem(address addr, string calldata cid) external view returns (FileItem memory);
}
