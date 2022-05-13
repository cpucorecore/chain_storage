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

    function offline(address addr) external;

    function setMaxFinishedTid(address addr, uint256 tid) external;
    function setStatus(address addr, uint256 status) external;

    function setMaintainCount(address addr, uint256 value) external;
    function setOfflineCount(address addr, uint256 value) external;

    function setTaskAddFileFinishCount(address addr, uint256 value) external;
    function setTaskAddFileFailCount(address addr, uint256 value) external;
    function setTaskDeleteFileFinishCount(address addr, uint256 value) external;
    function setTaskAcceptTimeoutCount(address addr, uint256 value) external;
    function setTaskTimeoutCount(address addr, uint256 value) external;

    function addNodeCid(address addr, string calldata cid) external;
    function removeNodeCid(address addr, string calldata cid) external;

    function setAddFileFailedCount(string calldata cid, uint256 count) external;
}
