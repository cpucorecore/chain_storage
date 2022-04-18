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

    function newTask(string memory cid, string memory pid, uint256 size, Action action, uint256 block) public returns(uint256) {
        tasks[tid] = TaskItem(cid, pid, size, action, Status.Created, 0, block, 0, 0, true);
        uint256 _tid = tid;
        tid = tid.add(1);
        return _tid;
    }

    function exist(uint256 tid) external view returns (bool) {
        return tasks[tid].exist;
    }

    function cid(uint256 tid) public returns(string memory) {
        return tasks[tid].cid;
    }

    function pid(uint256 tid) public returns(string memory) {
        return tasks[tid].pid;
    }

    function status(uint256 tid) public returns(Status) {
        return tasks[tid].status;
    }

    function setStatus(uint256 tid, Status status) public {// TODO check authority
        tasks[tid].status = status;
    }

    function setAcceptBlock(uint256 tid, uint256 block) external {
        tasks[tid].acceptBlock = block;
    }

    function setEndBlock(uint256 tid, uint256 block) external {
        tasks[tid].endBlock = block;
    }
}
