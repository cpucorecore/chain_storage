pragma solidity ^0.5.17;

interface IFile {
    function addFile(string calldata cid, uint size, address owner) external;
    function delFile(string calldata cid, address owner) external returns(bool);

    function exist(string calldata cid) public;
    function size(string calldata cid) public returns(uint);
    function addOwner(string calldata cid, address owner) public;

    function delOwner(string calldata cid, address owner) public returns(bool);
    function isOwnerOf(string calldata cid, address owner) public returns(bool);
    function owners(string calldata cid) returns(string[] memory);

    function addNode(string calldata cid, string memory pid) public;
    function delNode(string calldata cid, string memory pid) public;
    function nodeExist(string calldata cid, string memory pid) public returns(bool);
}