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
        uint256 used;
        uint256 space;
        EnumerableSet.Bytes32Set cidHashs;
        string ext;
        bool exist;
    }

    function newUser(address addr, uint256 space, string calldata ext) external;
    function deleteUser(address addr) external;
    function exist(address addr) external returns (bool);

    function space(address addr) external view returns (uint256);
    function setSpace(address addr, uint256 space) external;
    function used(address addr) external view returns (uint256);
    function spaceEnough(address addr, uint256 space) external view returns (bool);
    function useSpace(address addr, uint256 space) external;
    function freeSpace(address addr, uint256 space) external;

    function storageInfo(address addr) external returns (uint256, uint256);

    function cids(address addr) external returns (string[] memory);
    function fileExist(address addr, string calldata cid) external returns (bool);
    function addFile(address addr, string calldata cid, uint256 size, uint256 duration, string calldata ext) external;
    function deleteFile(address addr, string calldata cid) external;
    function fileCount(address addr) external returns (uint256);
}
