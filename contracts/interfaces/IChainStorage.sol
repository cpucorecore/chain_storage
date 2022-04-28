pragma solidity ^0.5.17;

interface IChainStorage {
    function userRegister(string calldata ext) external;
    function userAddFile(string calldata cid, uint256 size, uint256 duration, string calldata ext) external;
    function userDeleteFile(string calldata cid) external;
    function userSetExt(string calldata ext) external;
    function userSetFileExt(address addr, string calldata cid, string calldata ext) external;
    function userSetFileDuration(address addr, string calldata cid, uint256 duration) external;
    function changeUserSpace(address addr, uint256 space) external;

    function nodeRegister(uint256 space, string calldata ext) external;
    function nodeSetExt(string calldata ext) external;
    function nodeOnline() external;
    function nodeMaintain() external;
    function nodeAcceptTask(uint256 tid) external;
    function nodeFinishTask(uint256 tid) external;
    function nodeFailTask(uint256 tid) external;
    function changeNodeSpace(uint256 space) external;

    function monitorRegister(string calldata ext) external;
    function monitorOnline() external;
    function monitorMaintain() external;
    function monitorCheckTask(uint256 tid) external;
    function monitorResetCurrentTid(uint256 tid) external;
}
