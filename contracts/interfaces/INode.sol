pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

interface INode {
    function register(string calldata pid, uint256 storageSpace) external;
    function deRegister(string calldata pid) external;
    function online(string calldata pid) external;
    function offline(string calldata pid) external;
    function maintain(string calldata pid) external;
    function addFile(string calldata cid, uint256 size, uint256 duration) external;
    function pids() external view returns(string[] memory);
    function starve(string calldata pid) external view returns(uint256);

    function taskFinished(uint256 tid) external;
    function taskFailed(uint256 tid) external;
}
