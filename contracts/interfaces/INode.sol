pragma solidity ^0.5.2;

interface INode {
    function register(address addr, uint256 space, string calldata ext) external;
    function deRegister(address addr) external;
    function setExt(address addr, string calldata ext) external;
    function changeSpace(address addr, uint256 space) external;
    function online(address addr) external;
    function maintain(address addr) external;
}
