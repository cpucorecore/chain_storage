pragma solidity ^0.5.2;

interface INode {
    function register(address addr, uint256 storageTotal, string calldata ext) external;
    function setExt(address addr, string calldata ext) external;
    function setStorageTotal(address addr, uint256 storageTotal) external;
    function deRegister(address addr) external;

    function online(address addr) external;
    function maintain(address addr) external;

    function addFile(address owner, string calldata cid) external;

    function finishTask(address addr, uint256 tid, uint256 size) external;
    function failTask(address addr, uint256 tid) external;

    function reportAcceptTaskTimeout(uint256 tid) external;
    function reportTaskTimeout(uint256 tid) external;
}
