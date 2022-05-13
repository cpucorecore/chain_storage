pragma solidity ^0.5.2;

interface INodeStorage {
    function newNode(address addr, uint256 storageTotal, string calldata ext) external;
    function deleteNode(address addr) external;

    function setStorageTotal(address addr, uint256 value) external;
    function useStorage(address addr, uint256 value) external;
    function freeStorage(address addr, uint256 value) external;
    function setExt(address addr, string calldata ext) external;

    function addOnlineNode(address addr) external;
    function deleteOnlineNode(address addr) external;

    function setMaxFinishedTid(address addr, uint256 tid) external;
    function setStatus(address addr, uint256 status) external;

    function resetAddFileFailedCount(string calldata cid) external;
    function upAddFileFailedCount(string calldata cid) external returns (uint256);

    function exist(address addr) external view returns (bool);

    function isNodeOnline(address addr) external view returns (bool);

    function getStorageInfo(address addr) external view returns (uint256, uint256); // (used, total)

    function getMaxFinishedTid(address addr) external view returns (uint256);

    function getStatus(address addr) external view returns (uint256);

    function availableSpace(address addr) external view returns (uint256);
    function getStorageTotal(address addr) external view returns (uint256);

    function getStorageUsed(address addr) external view returns (uint256);

    function getExt(address addr) external view returns (string memory);

    function getAllNodeAddresses() external view returns (address[] memory);
    function getAllNodeAddresses(uint256 pageSize, uint256 pageNumber) external view returns (address[] memory, bool);

    function getAllOnlineNodeAddresses() external view returns (address[] memory);
    function getAllOnlineNodeAddresses(uint256 pageSize, uint256 pageNumber) external view returns (address[] memory, bool);

    function getAddFileFailedCount(string calldata cid) external view returns (uint256);

    function getTotalNodeNumber() external view returns (uint256);
    function getTotalOnlineNodeNumber() external view returns (uint256);
}
