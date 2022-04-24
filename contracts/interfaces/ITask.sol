pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import "./storages/ITaskStorage.sol";

interface ITask {
    function issueTask(ITaskStorage.Action action, address owner, string calldata cid, address node, uint256 size) external returns (uint256);
    function getCurrentTid() external view returns (uint256);
    function getTaskItem(uint256 tid) external view returns (ITaskStorage.TaskItem memory);

    function getCreateTime(uint256 tid) external view returns (uint256);
    function getCreateBlockNumber(uint256 tid) external view returns (uint256);
    function getStatusInfo(uint256 tid) external view returns (ITaskStorage.StatusInfo memory);

    function getAddFileTaskProgress(uint256 tid) external view returns (ITaskStorage.AddFileTaskProgress memory);

    function acceptTask(uint256 tid) external;
    function finishTask(uint256 tid) external;
    function failTask(uint256 tid) external;
    function TaskAcceptTimeout(uint256 tid) external;
    function TaskTimeout(uint256 tid) external;
    function reportAddFileProgress(uint256 tid, uint256 size) external;
}
