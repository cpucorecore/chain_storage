pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import "../lib/Paging.sol";

interface IFile {
    function addFile(string calldata cid, uint size, address owner) external;
    function deleteFile(string calldata cid, address owner) external;
    function exist(string calldata cid) external view returns (bool);
    function getSize(string calldata cid) external view returns (uint256);

    function fileAdded(string calldata cid, address node) external;
    function fileDeleted(string calldata cid, address node) external;

    function ownerExist(string calldata cid, address owner) external view returns (bool);
    function owners(string calldata cid, uint256 pageSize, uint256 pageNumber) external view returns (address[] memory, Paging.Page memory);
}
