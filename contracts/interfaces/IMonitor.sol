pragma solidity ^0.5.2;
pragma experimental ABIEncoderV2;

interface IMonitor {
    function register(address addr, string calldata ext) external;
    function deRegister(address addr) external;

    function online(address addr) external;
    function maintain(address addr) external;

    function resetCurrentTid(address addr, uint256 tid) external;
    function reportTaskAcceptTimeout(address addr, uint256 tid) external;
    function reportTaskTimeout(address addr, uint256 tid) external;
}
