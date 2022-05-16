pragma solidity ^0.5.2;

interface INode {
    function register(address addr, uint256 storageTotal, string calldata ext) external;
    function deRegister(address addr) external;
    function setExt(address addr, string calldata ext) external;
    function setStorageTotal(address addr, uint256 storageTotal) external;
    function online(address addr) external;
    function maintain(address addr) external;

    function addFile(address owner, string calldata cid) external;
}
