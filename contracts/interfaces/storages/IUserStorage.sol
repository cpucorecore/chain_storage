pragma solidity ^0.5.2;
pragma experimental ABIEncoderV2;

interface IUserStorage {
    function newUser(address addr, uint256 storageTotal, string calldata ext) external;
    function deleteUser(address addr) external;
    function setExt(address addr, string calldata ext) external;
    function setStorageTotal(address addr, uint256 size) external;
    function upInvalidAddFileCount(address addr) external returns (uint256);
    function useStorage(address addr, uint256 size) external;
    function freeStorage(address addr, uint256 size) external;
    function exist(address addr) external view returns (bool);
    function getExt(address addr) external view returns (string memory);
    function availableSpace(address addr) external view returns (uint256);
    function getStorageTotal(address addr) external view returns (uint256);
    function getStorageUsed(address addr) external view returns (uint256);
    function getFileNumber(address addr) external view returns (uint256);
    function getCids(address addr, uint256 pageSize, uint256 pageNumber) external view returns (string[] memory, bool);
    function getInvalidAddFileCount(address addr) external view returns (uint256);

    function addFile(address addr, string calldata cid, uint256 duration, string calldata ext, uint256 createTime) external;
    function deleteFile(address addr, string calldata cid) external;
    function setFileExt(address addr, string calldata cid, string calldata ext) external;
    function setFileDuration(address addr, string calldata cid, uint256 duration) external;
    function fileExist(address addr, string calldata cid) external view returns (bool);
    function getFileExt(address addr, string calldata cid) external view returns (string memory);
    function getFileDuration(address addr, string calldata cid) external view returns (uint256);
    function getFileItem(address addr, string calldata cid) external view returns (string memory, uint256, uint256, string memory);

    function getTotalUserNumber() external view returns (uint256);
}
