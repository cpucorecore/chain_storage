pragma solidity ^0.5.2;
pragma experimental ABIEncoderV2;

interface IFile {
    function exist(string calldata cid) external view returns (bool);

    function addFile(string calldata cid, address owner) external;
    function addFileCallback(address node, address owner, string calldata cid, uint256 size) external;

    function deleteFile(string calldata cid, address owner) external;
    function deleteFileCallback(address node, address owner, string calldata cid) external;

    function getSize(string calldata cid) external view returns (uint256);

    function ownerExist(string calldata cid, address owner) external view returns (bool);
    function getOwners(string calldata cid) external view returns (address[] memory);
    function getOwners(string calldata cid, uint256 pageSize, uint256 pageNumber) external view returns (address[] memory, bool);

    function nodeExist(string calldata cid, address node) external view returns (bool);
    function getNodes(string calldata cid) external view returns (address[] memory);
    function getNodes(string calldata cid, uint256 pageSize, uint256 pageNumber) external view returns (address[] memory, bool);

    function getTotalSize() external view returns (uint256);
    function getTotalFileNumber() external view returns (uint256);
}
