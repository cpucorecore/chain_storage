pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import "../../lib/EnumerableSet.sol";

contract IFileStorage {
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.Bytes32Set;

    struct FileItem {
        bool exist;
        uint256 size;
        uint256 createdTime;
        EnumerableSet.AddressSet owners;
        EnumerableSet.Bytes32Set nodes;
    }

    function newFile(string memory cid, uint256 size, address owner, uint256 createdTime) public returns(bool);
    function deleteFile(string memory cid) public;
    function exist(string memory cid) public view returns(bool);
    function size(string memory cid) public view returns(uint256);
    function createdTime(string memory cid) public view returns(uint256);

    function ownerExist(string memory cid, address owner) public view returns(bool);
    function addOwner(string memory cid, address owner) public;
    function delOwner(string memory cid, address owner) public;
    function owners(string memory cid) public returns(address[] memory);

    function nodeExist(string memory cid, string memory pid) public view returns(bool);
    function addNode(string memory cid, string memory pid) public;
    function delNode(string memory cid, string memory pid) public;
    function nodes(string memory cid) public returns(string[] memory);
}
