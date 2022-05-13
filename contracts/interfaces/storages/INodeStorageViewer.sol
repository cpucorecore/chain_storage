pragma solidity ^0.5.2;
pragma experimental ABIEncoderV2;

interface INodeStorageViewer {
    function exist(address addr) external view returns (bool);

    function isNodeOnline(address addr) external view returns (bool);

    function getStorageInfo(address addr) external view returns (uint256, uint256); // (used, total)

    function getMaxFinishedTid(address addr) external view returns (uint256);

    function getStatus(address addr) external view returns (uint256);

    function getStorageFree(address addr) external view returns (uint256);
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
