pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import "../lib/Paging.sol";
import "./storages/IUserStorage.sol";

interface IUser {
    function register(address addr, string calldata ext) external;
    function deRegister(address addr) external;
    function exist(address addr) external returns(bool);
    function addFile(address addr, string calldata cid, uint256 size, uint256 duration, string calldata ext) external;
    function deleteFile(address addr, string calldata cid) external;
    function changeSpace(address addr, uint256 size) external;// only admin
    function getCids(address addr, uint256 pageSize, uint256 pageNumber) external view returns (string[] memory, Paging.Page memory);
    function getStorageInfo(address addr) external view returns (IUserStorage.StorageInfo memory);
}
