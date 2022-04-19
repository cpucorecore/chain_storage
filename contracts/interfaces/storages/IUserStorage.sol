pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import "./INodeStorage.sol";
import "../../lib/EnumerableSet.sol";

interface IUserStorage {
    using EnumerableSet for EnumerableSet.UintSet;

    struct FileInfo {
        uint256 fid;
        uint256 duration;
        string ext;
        bool exist;
    }

    struct UserItem {
        uint256 used;
        uint256 space;
        EnumerableSet.UintSet fids;
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
    function storageInfo(address addr) external view returns (uint256, uint256);

    function addFile(address addr, string calldata cid, uint256 fid, uint256 duration, string calldata ext) external;
    function deleteFile(address addr, string calldata cid) external;
    function fileExist(address addr, string calldata cid) external view returns (bool);
    function fileNumber(address addr) external view returns (uint256);
    function cids(address addr, uint256 pageSize, uint256 pageNumber) external view returns (string[] memory, Paging.Page memory);
}
