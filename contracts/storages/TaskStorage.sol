pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import "../interfaces/storages/ITaskStorage.sol";
import "./ExternalStorage.sol";

contract TaskStorage is ExternalStorage, ITaskStorage {
    uint256 private tid;
    mapping(uint256=>TaskItem) tasks;

    function currentTid() public view returns(uint256) {
        return tid;
    }

    function newTask(string memory cid, address node, uint256 size, Action action, uint256 block) public returns(uint256) {
        tid = tid.add(1);
        tasks[tid] = TaskItem(cid, node, size, action, Status.Created, block, 0, 0, 0, 0, true);
        return tid;
    }

    function exist(uint256 tid) external view returns (bool) {
        return tasks[tid].exist;
    }
    function cid(uint256 tid) external view returns (string memory) {
        return tasks[tid].cid;
    }

    function node(uint256 tid) external view returns (address) {
        return tasks[tid].node;
    }

    function status(uint256 tid) external view returns (Status) {
        return tasks[tid].status;
    }

    function setStatus(uint256 tid, Status status) public {// TODO check authority
        tasks[tid].status = status;
    }

    function acceptTimeoutBlock(uint256 tid) external view returns (uint256) {
        return tasks[tid].acceptTimeoutBlock;
    }

    function setAcceptTimeoutBlock(uint256 tid, uint256 block) external {
        tasks[tid].acceptTimeoutBlock = block;
    }

    function acceptedBlock(uint256 tid) external view returns (uint256) {
        return tasks[tid].acceptedBlock;
    }

    function setAcceptedBlock(uint256 tid, uint256 block) external {
        tasks[tid].acceptedBlock = block;
    }

    function timeoutBlock(uint256 tid) external view returns (uint256) {
        return tasks[tid].timeoutBlock;
    }

    function setTimeoutBlock(uint256 tid, uint256 block) external {
        tasks[tid].timeoutBlock = block;
    }

    function finishedBlock(uint256 tid) external view returns (uint256) {
        return tasks[tid].FinishedBlock;
    }

    function setFinishedBlock(uint256 tid, uint256 block) external {
        tasks[tid].FinishedBlock = block;
    }

    function blockInfo(uint256 tid) external view returns (uint256, uint256, uint256, uint256, uint256) {
        return (tasks[tid].createdBlock,
                tasks[tid].acceptTimeoutBlock,
                tasks[tid].acceptedBlock,
                tasks[tid].timeoutBlock,
                tasks[tid].FinishedBlock);
    }
}
