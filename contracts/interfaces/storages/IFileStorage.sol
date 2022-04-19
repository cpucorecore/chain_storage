pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import "../../lib/EnumerableSet.sol";
import "../../lib/Paging.sol";

contract IFileStorage {
    using EnumerableSet for EnumerableSet.AddressSet;

    struct FileItem {
        string cid;
        uint256 size;
        EnumerableSet.AddressSet owners;
        EnumerableSet.AddressSet nodes;
        bool exist;
    }

    function newFile(string calldata cid, uint256 size, address owner, uint256 duration) external returns (uint256);
    function deleteFile(uint256 fid) external;
    function exist(uint256 fid) public view returns (bool);
    function exist(string memory cid) public view returns (bool);
    function size(uint256 fid) public view returns (uint256);
    function size(string calldata cid) external view returns (uint256);
    function cid(uint256 fid) external view returns (string memory);
    function fid(string calldata cid) external view returns (uint256);
    function duration(uint256 fid) external view returns (uint256);

    function ownerExist(uint256 fid, address owner) external view returns (bool);
    function addOwner(uint256 fid, address owner) public;
    function delOwner(uint256 fid, address owner) public;
    function owners(uint256 fid, uint256 pageSize, uint256 pageNumber) external view returns (address[] memory, Paging.Page memory);
    function owners(uint256 fid) external view returns (address[] memory);

    function nodeExist(uint256 fid, address node) external view returns (bool);
    function addNode(uint256 fid, address node) public;
    function delNode(uint256 fid, address node) public;
    function nodes(uint256 fid, uint256 pageSize, uint256 pageNumber) external view returns (address[] memory, Paging.Page memory);
    function nodes(uint256 fid) external view returns (address[] memory);
}
