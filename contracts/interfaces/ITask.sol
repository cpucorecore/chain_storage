pragma solidity ^0.5.2;

interface ITask {
    function issueTask(uint256 action, address userAddress, string calldata cid, address nodeAddress, bool noCallback) external returns (uint256);
    function acceptTask(address nodeAddress, uint256 tid) external;
    function finishTask(uint256 tid) external;
    function failTask(uint256 tid) external;
    function acceptTaskTimeout(uint256 tid) external;
    function taskTimeout(uint256 tid) external;
    function reportAddFileProgressBySize(address nodeAddress, uint256 tid, uint256 size) external;
    function reportAddFileProgressByPercentage(address nodeAddress, uint256 tid, uint256 percentage) external;

    function getCurrentTid() external view returns (uint256);
    function getNodeMaxTid(address nodeAddress) external view returns (uint256);
    function exist(uint256 tid) external view returns (bool);
    function isOver(uint256 tid) external view returns (bool);
    function getTask(uint256 tid) external view returns (address, uint256, address, bool, string memory);
    function getTaskState(uint256 tid) external view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256);
    function getAddFileTaskProgress(uint256 tid) external view returns (uint256, uint256, uint256, uint256, uint256, uint256);
}
