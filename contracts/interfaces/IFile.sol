pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import "../lib/Paging.sol";

interface IFile {
    function addFile(string calldata cid, uint size, address owner, uint256 duration) external returns (uint256);
    function deleteFile(string calldata cid, address owner) external;
    function exist(string calldata cid) external view returns (bool);
    function fid(string calldata cid) external view returns (uint256);
    function size(string calldata cid) external view returns (uint256);

    function fileAdded(string calldata cid, address node) external;
    function fileDeleted(string calldata cid, address node) external;

    function owners(string calldata cid, uint256 pageSize, uint256 pageNumber) external view returns (address[] memory, Paging.Page memory);
}
