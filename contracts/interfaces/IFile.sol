pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import "../lib/Paging.sol";
import "./storages/IFileStorage.sol";

interface IFile {
    function addFile(string calldata cid, uint256 size, address owner) external;
    function deleteFile(string calldata cid, address owner) external;
    function exist(string calldata cid) external view returns (bool);

    function getStatus(string calldata cid) external view returns (IFileStorage.Status);
    function getSize(string calldata cid) external view returns (uint256);
    function fileAdded(address node, address owner, string calldata cid) external;
    function fileDeleted(address node, address owner, string calldata cid) external;

    function ownerExist(string calldata cid, address owner) external view returns (bool);
    function getOwners(string calldata cid) external view returns (address[] memory);
    function getOwners(string calldata cid, uint256 pageSize, uint256 pageNumber) external view returns (address[] memory, Paging.Page memory);

    function nodeExist(string calldata cid, address node) external view returns (bool);
    function getNodes(string calldata cid) external view returns (address[] memory);
    function getNodes(string calldata cid, uint256 pageSize, uint256 pageNumber) external view returns (address[] memory, Paging.Page memory);
}
