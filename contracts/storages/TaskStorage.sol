pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import "../interfaces/storages/ITaskStorage.sol";
import "./ExternalStorage.sol";

contract TaskStorage is ExternalStorage, ITaskStorage {
    uint256 private tid;
    mapping(uint256=>TaskItem) private tid2taskItem;
    mapping(uint256=>TaskStatus) private tid2taskStatus;
    mapping(uint256=>AddFileTaskProgress) private tid2addFileTaskProgress;

    function newTask(string memory cid, address node, uint256 size, Action action, uint256 block, uint256 duration) public returns(uint256) {
        tid = tid.add(1);
        tasks[tid] = TaskItem(cid, node, size, duration, action, Status.Created, block, 0, 0, 0, 0, 0, true);
        return tid;
    }

    function newTask(
        address owner,
        Action action,
        string calldata cid,
        uint256 size,
        address node,
        uint256 createBlock,
        uint256 createTime
    ) external returns (uint256) {
        tid = tid.add(1);
        tid2taskItem[tid] = TaskItem(owner, action, node, size, cid, true);
        tid2taskStatus[tid] = TaskStatus(ITaskStorage.Status.Created, block.number, block.timestamp, 0, 0, 0, 0, 0, true);
        if(ITaskStorage.Action.Add == action) {
            tid2addFileTaskProgress[tid] = AddFileTaskProgress(0, 0, 0, true);
        }
        return tid;
    }

    function exist(uint256 tid) external view returns (bool) {
        return tid2taskItem[tid].exist && tid2taskStatus[tid].exist;
    }

    function getTaskItem(uint256 tid) external view returns (TaskItem memory) {
        return tid2taskItem[tid];
    }

    function getTaskStatus(uint256 tid) external view returns (TaskStatus memory) {
        return tid2taskStatus[tid];
    }

    function getAddFileTaskProgress(uint256 tid) external view returns (AddFileTaskProgress memory) {
        return tid2addFileTaskProgress[tid];
    }
}
