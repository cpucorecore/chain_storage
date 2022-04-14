pragma solidity ^0.5.17;

import "./INodeStorage.sol";
import "../../lib/EnumerableSet.sol";
pragma experimental ABIEncoderV2;

interface IUserStorage {
    using EnumerableSet for EnumerableSet.Bytes32Set;

    struct FileInfo {
        bool exist;
        uint256 size;
        uint256 duration;
        string cid;
        string ext;
    }

    struct UserItem {
        bool exist;
        uint256 used;
        uint256 space;
        EnumerableSet.Bytes32Set cidHashs;
    }

    function newUser(address addr, uint256 storageSpace) external;
    function deleteUser(address addr) external;
    function exist(address addr) external returns(bool);

    function storageSpace(address addr) external returns(uint256);
    function storageSpace(address addr, uint256 storageSpace) external;
    function storageUsed(address addr) external returns(uint256);
    function storageUsed(address addr, uint256 storageSpace) external;

    function useStorage(address addr, uint256 storageUsed) external;
    function storageInfo(address addr) external returns(uint256, uint256);

    function cids(address addr) external returns(string[] memory);
    function addFile(address addr, string calldata cid, uint256 size, uint256 duration, string calldata ext) external;
    function deleteFile(address addr, string calldata cid) external;
    function fileCount(address addr) external returns(uint256);
}
