pragma solidity ^0.5.2;
pragma experimental ABIEncoderV2;

contract IFileStorage {
    function exist(string memory cid) public view returns (bool);
    function newFile(string calldata cid, uint256 size) external;
    function deleteFile(string calldata cid) external;

    function getSize(string calldata cid) external view returns (uint256);
    function setSize(string calldata cid, uint256 size) external;

    function ownerExist(string calldata cid, address owner) external view returns (bool);
    function ownerEmpty(string calldata cid) external view returns (bool);
    function addOwner(string calldata cid, address owner) external;
    function deleteOwner(string calldata cid, address owner) external;
    function getOwners(string calldata cid) external view returns (address[] memory);
    function getOwners(string calldata cid, uint256 pageSize, uint256 pageNumber) external view returns (address[] memory, bool);

    function nodeExist(string calldata cid, address node) external view returns (bool);
    function nodeEmpty(string calldata cid) external view returns (bool);
    function addNode(string calldata cid, address node) external;
    function deleteNode(string calldata cid, address node) external;
    function getNodes(string calldata cid) external view returns (address[] memory);
    function getNodes(string calldata cid, uint256 pageSize, uint256 pageNumber) external view returns (address[] memory, bool);

    function getTotalSize() external view returns (uint256);
    function getTotalFileNumber() external view returns (uint256);
}
