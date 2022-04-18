pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import "../lib/Paging.sol";

interface IMonitor {
    function register(address addr, string calldata ext) external;
    function deRegister(address addr) external;
    function online(address addr) external;
    function maintain(address addr) external;
    function reportTaskTimeout(address addr, uint256 tid) external;
}
