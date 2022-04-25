pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import "../../lib/Paging.sol";

contract IFileStorage {
    enum Status {
        Adding,
        Added,
        Deleting
    }

    function newFile(string calldata cid, uint256 size) external;
    function deleteFile(string calldata cid) external;
    function exist(string memory cid) public view returns (bool);

    function getStatus(string calldata cid) external view returns (Status);
    function setStatus(string calldata cid, Status status) external;

    function getSize(string calldata cid) external view returns (uint256);

    function ownerExist(string calldata cid, address owner) external view returns (bool);
    function ownerEmpty(string calldata cid) external view returns (bool);
    function addOwner(string calldata cid, address owner) external;
    function deleteOwner(string calldata cid, address owner) external;
    function getOwners(string calldata cid, uint256 pageSize, uint256 pageNumber) external view returns (address[] memory, Paging.Page memory);
    function getOwners(string calldata cid) external view returns (address[] memory);

    function nodeExist(string calldata cid, address node) external view returns (bool);
    function nodeEmpty(string calldata cid) external view returns (bool);
    function addNode(string calldata cid, address node) external;
    function deleteNode(string calldata cid, address node) external;
    function getNodes(string calldata cid, uint256 pageSize, uint256 pageNumber) external view returns (address[] memory, Paging.Page memory);
    function getNodes(string calldata cid) external view returns (address[] memory);
}
