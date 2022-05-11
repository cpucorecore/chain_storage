pragma solidity ^0.5.2;
pragma experimental ABIEncoderV2;

import "./base/Importable.sol";
import "./base/ExternalStorable.sol";
import "./interfaces/ITask.sol";
import "./interfaces/storages/ITaskStorage.sol";

contract Task is Importable, ExternalStorable, ITask {
    event TaskIssued(address indexed node, uint256 indexed tid);
    event TaskStatusChanged(uint256 indexed tid, ITaskStorage.Status, uint256 timestamp);

    bytes32[] private ISSUEABLE_CONTRACTS = [CONTRACT_NODE, CONTRACT_FILE];

    constructor(IResolver _resolver) public Importable(_resolver) {
        setContractName(CONTRACT_TASK);
    }

    function Storage() private view returns(ITaskStorage) {
        return ITaskStorage(getStorage());
    }

    function exist(uint256 tid) external view returns (bool) {
        return Storage().exist(tid);
    }

    function getCurrentTid() external view returns (uint256) {
        return Storage().getCurrentTid();
    }

    function getNodeMaxTid(address addr) external view returns (uint256) {
        return Storage().getNodeMaxTid(addr);
    }

    function isOver(uint256 tid) external view returns (bool) {
        return Storage().isOver(tid);
    }

    function issueTask(ITaskStorage.Action action, address owner, string calldata cid, address node, uint256 size) external containAddress(ISSUEABLE_CONTRACTS) returns (uint256) {
        uint256 tid = Storage().newTask(owner, action, cid, size, node);
        emit TaskIssued(node, tid);
        return tid;
    }

    function getTask(uint256 tid) external view returns (address, ITaskStorage.Action, address, uint256, string memory) {
        return Storage().getTask(tid);
    }

    function getAction(uint256 tid) external view returns (ITaskStorage.Action) {
        return Storage().getAction(tid);
    }

    function getOwner(uint256 tid) external view returns (address) {
        return Storage().getOwner(tid);
    }

    function getNode(uint256 tid) external view returns (address) {
        return Storage().getNode(tid);
    }

    function getSize(uint256 tid) external view returns (uint256) {
        return Storage().getSize(tid);
    }

    function getCid(uint256 tid) external view returns (string memory) {
        return Storage().getCid(tid);
    }

    function getTaskState(uint256 tid) external view returns (ITaskStorage.Status, uint256, uint256, uint256, uint256, uint256, uint256, uint256) {
        return Storage().getTaskState(tid);
    }

    function getStatus(uint256 tid) external view returns (ITaskStorage.Status) {
        return Storage().getStatus(tid);
    }

    function getCreateBlockNumber(uint256 tid) external view returns (uint256) {
        return Storage().getCreateBlockNumber(tid);
    }

    function getCreateTime(uint256 tid) external view returns (uint256) {
        return Storage().getCreateTime(tid);
    }

    function getAcceptTime(uint256 tid) external view returns (uint256) {
        return Storage().getAcceptTime(tid);
    }

    function getAcceptTimeoutTime(uint256 tid) external view returns (uint256) {
        return Storage().getAcceptTimeoutTime(tid);
    }

    function getFinishTime(uint256 tid) external view returns (uint256) {
        return Storage().getFinishTime(tid);
    }

    function getFailTime(uint256 tid) external view returns (uint256) {
        return Storage().getFailTime(tid);
    }

    function getTimeoutTime(uint256 tid) external view returns (uint256) {
        return Storage().getTimeoutTime(tid);
    }

    function getStatusAndTime(uint256 tid) external view returns (ITaskStorage.Status, uint256) {
        return Storage().getStatusAndTime(tid);
    }

    function setStatusAndTime(uint256 tid, ITaskStorage.Status status, uint256 time) private {
        Storage().setStatusAndTime(tid, status, time);
    }

    function getAddFileTaskProgress(uint256 tid) external view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        return Storage().getAddFileTaskProgress(tid);
    }

    function acceptTask(address node, uint256 tid) external onlyAddress(CONTRACT_CHAIN_STORAGE) {
        checkTaskExist(tid);

        address taskNode = Storage().getNode(tid);
        require(node == taskNode, contractName.concat(": node have no this task"));

        ITaskStorage.Action action = Storage().getAction(tid);
        ITaskStorage.Status status = Storage().getStatus(tid);
        if(ITaskStorage.Action.Add == action) {
            require(ITaskStorage.Status.Created == status, contractName.concat(": add file task status is not Created"));
        } else {
            require(ITaskStorage.Status.Created == status ||
                    ITaskStorage.Status.AcceptTimeout == status ||
                    ITaskStorage.Status.Timeout == status,
                contractName.concat(": delete file task status is not in [Created,AcceptTimeout,Timeout]"));
        }

        Storage().setStatusAndTime(tid, ITaskStorage.Status.Accepted, now);
        emit TaskStatusChanged(tid, ITaskStorage.Status.Accepted, now);
    }

    function finishTask(uint256 tid) external onlyAddress(CONTRACT_NODE) {
        checkTaskExist(tid);

        ITaskStorage.Status status = Storage().getStatus(tid);
        require(ITaskStorage.Status.Accepted == status, contractName.concat(": task status is not Accepted"));

        Storage().setStatusAndTime(tid, ITaskStorage.Status.Finished, now);
        emit TaskStatusChanged(tid, ITaskStorage.Status.Finished, now);
    }

    function failTask(uint256 tid) external onlyAddress(CONTRACT_NODE) {
        checkTaskExist(tid);

        ITaskStorage.Action action = Storage().getAction(tid);
        require(ITaskStorage.Action.Add == action, contractName.concat(": only add file task can fail"));

        ITaskStorage.Status status = Storage().getStatus(tid);
        require(ITaskStorage.Status.Accepted == status, contractName.concat(": task status is not Accepted"));

        Storage().setStatusAndTime(tid, ITaskStorage.Status.Failed, now);
        emit TaskStatusChanged(tid, ITaskStorage.Status.Failed, now);
    }

    function acceptTaskTimeout(uint256 tid) external onlyAddress(CONTRACT_NODE) {
        checkTaskExist(tid);

        ITaskStorage.Status status = Storage().getStatus(tid);
        require(ITaskStorage.Status.Created == status, contractName.concat(": task status is not Created"));

        Storage().setStatusAndTime(tid, ITaskStorage.Status.AcceptTimeout, now);
        emit TaskStatusChanged(tid, ITaskStorage.Status.AcceptTimeout, now);
    }

    function taskTimeout(uint256 tid) external onlyAddress(CONTRACT_NODE) {
        checkTaskExist(tid);

        ITaskStorage.Status status = Storage().getStatus(tid);
        require(ITaskStorage.Status.Accepted == status, contractName.concat(": task status is not Accepted"));

        Storage().setStatusAndTime(tid, ITaskStorage.Status.Timeout, now);
        emit TaskStatusChanged(tid, ITaskStorage.Status.Timeout, now);
    }

    function reportAddFileProgressBySize(address addr, uint256 tid, uint256 size) external onlyAddress(CONTRACT_NODE) { // TODO
        checkTaskExist(tid);

        address node = Storage().getNode(tid);
        require(addr == node, contractName.concat(": node have no this task"));

        ITaskStorage.Status status = Storage().getStatus(tid);
        require(ITaskStorage.Status.Accepted == status, contractName.concat(": task status is not Accepted"));

        Storage().setAddFileTaskProgressBySize(tid, now, size);
    }

    function reportAddFileProgressByPercentage(address addr, uint256 tid, uint256 percentage) external onlyAddress(CONTRACT_NODE) { // TODO
        checkTaskExist(tid);

        address node = Storage().getNode(tid);
        require(addr == node, contractName.concat(": node have no this task"));

        ITaskStorage.Status status = Storage().getStatus(tid);
        require(ITaskStorage.Status.Accepted == status, contractName.concat(": task status is not Accepted"));

        Storage().setAddFileTaskProgressByPercentage(tid, now, percentage);
    }

    function checkTaskExist(uint256 tid) private {
        require(Storage().exist(tid), contractName.concat(": task not exist"));
    }
}
