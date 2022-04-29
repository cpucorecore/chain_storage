pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import "../lib/Paging.sol";
import "./storages/IUserStorage.sol";

interface IUser {
    function exist(address addr) external returns (bool);
    function register(address addr, string calldata ext) external;
    function deRegister(address addr) external;

    function getExt(address addr) external view returns (string memory);
    function setExt(address addr, string calldata ext) external;

    function changeSpace(address addr, uint256 size) external;
    function getStorageInfo(address addr) external view returns (IUserStorage.StorageInfo memory);

    function addFile(address addr, string calldata cid, uint256 size, uint256 duration, string calldata ext) external;
    function callbackFinishAddFile(address owner, address node, string calldata cid) external;
    function callbackFailAddFile(address owner, string calldata cid) external;

    function deleteFile(address addr, string calldata cid) external;
    function callbackFinishDeleteFile(address owner, address node, string calldata cid) external;

    function getFileExt(address addr, string calldata cid) external view returns (string memory);
    function setFileExt(address addr, string calldata cid, string calldata ext) external;

    function getFileDuration(address addr, string calldata cid) external view returns (uint256);
    function setFileDuration(address addr, string calldata cid, uint256 duration) external;

    function getCids(address addr, uint256 pageSize, uint256 pageNumber) external view returns (string[] memory, Paging.Page memory);

    function getTotalUserNumber() external view returns (uint256);
}
