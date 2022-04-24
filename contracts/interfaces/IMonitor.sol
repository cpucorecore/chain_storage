pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import "../lib/Paging.sol";

interface IMonitor {
    function register(address addr, string calldata ext) external;
    function deRegister(address addr) external;
    function exist(address addr) external returns (bool);

    function online(address addr) external;
    function maintain(address addr) external;

    function checkTask(address addr, uint256 tid) external;
    function loadCurrentTid(address addr) external returns (uint256);
    function resetCurrentTid(address addr, uint256 tid) external;
}
