pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import "../../lib/Paging.sol";

contract IFileStorage {
    function newFile(string calldata cid, uint256 size) external;
    function deleteFile(string calldata cid) external;
    function exist(string memory cid) public view returns (bool);
    function size(string calldata cid) external view returns (uint256);

    function ownerExist(string calldata cid, address owner) external view returns (bool);
    function ownerEmpty(string calldata cid) external view returns (bool);
    function addOwner(string calldata cid, address owner) external;
    function delOwner(string calldata cid, address owner) external;
    function owners(string calldata cid, uint256 pageSize, uint256 pageNumber) external view returns (address[] memory, Paging.Page memory);
    function owners(string calldata cid) external view returns (address[] memory);

    function nodeExist(string calldata cid, address node) external view returns (bool);
    function nodeEmpty(string calldata cid) external view returns (bool);
    function addNode(string calldata cid, address node) external;
    function delNode(string calldata cid, address node) external;
    function nodes(string calldata cid, uint256 pageSize, uint256 pageNumber) external view returns (address[] memory, Paging.Page memory);
    function nodes(string calldata cid) external view returns (address[] memory);
}
