pragma solidity ^0.5.17;

interface IChainStorage {
    function userRegister() external returns (bool);
    function userAddFile(string calldata cid, uint256 size, uint256 duration, string calldata ext) external returns (bool);
    function userDeleteFile(string calldata cid) external returns (bool);

    function nodeRegister(string calldata pid, uint256 space) external returns (bool);
    function nodeOnline() external returns (bool);
}
