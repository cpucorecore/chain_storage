pragma solidity ^0.5.17;

interface IChainStorage {
    function userRegister(uint256 space, string calldata ext) external;
    function userAddFile(string calldata cid, uint256 size, uint256 duration, string calldata ext) external;
    function userDeleteFile(string calldata cid) external;

    function nodeRegister(string calldata pid, uint256 space) external;
    function nodeOnline() external;

    function monitorRegister(string calldata ext) external;
    function monitorOnline() external;
}
