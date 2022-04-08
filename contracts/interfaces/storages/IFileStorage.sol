pragma solidity ^0.5.17;

contract IFileStorage {
    function newFile(string memory cid, uint256 size, address owner, uint256 createdTime) public returns(bool);
    function exist(string memory cid) public view returns(bool);
    function size(string memory cid) public view returns(uint256);
    function createdTime(string memory cid) public view returns(uint256);

    function ownerExist(string memory cid, address owner) public view returns(bool);
    function addOwner(string memory cid, address owner) public;
    function delOwner(string memory cid, address owner) public;

    function nodeExist(string memory cid, string memory pid) public view returns(bool);
    function addNode(string memory cid, string memory pid) public;
    function delNode(string memory cid, string memory pid) public;
}
