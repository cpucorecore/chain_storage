pragma solidity ^0.5.2;
pragma experimental ABIEncoderV2;

import "./base/Importable.sol";
import "./base/ExternalStorable.sol";
import "./interfaces/ITask.sol";
import "./interfaces/storages/ITaskStorage.sol";

contract Task is Importable, ExternalStorable, ITask {
    event TaskIssued(address indexed node, uint256 indexed tid);

    constructor(IResolver _resolver) public Importable(_resolver) {
        setContractName(CONTRACT_TASK);
        imports = [
            CONTRACT_FILE,
            CONTRACT_USER,
            CONTRACT_NODE
        ];
    }

    function Storage() private view returns(ITaskStorage) {
        return ITaskStorage(getStorage());
    }

    function issueTask(ITaskStorage.Action action, address owner, string calldata cid, address node, uint256 size) external returns (uint256) {
        uint256 tid = Storage().newTask(owner, action, cid, size, node, block.number, now);
        emit TaskIssued(node, tid);
        return tid;
    }

    function getCurrentTid() external view returns (uint256) {
        return Storage().getCurrentTid();
    }

    function getNodeMaxTid(address addr) external view returns (uint256) {
        return Storage().getNodeMaxTid(addr);
    }

    function getTaskItem(uint256 tid) external view returns (ITaskStorage.TaskItem memory) {
        return Storage().getTaskItem(tid);
    }

    function getCreateTime(uint256 tid) external view returns (uint256) {
        return Storage().getCreateTime(tid);
    }

    function getCreateBlockNumber(uint256 tid) external view returns (uint256) {
        return Storage().getCreateBlockNumber(tid);
    }

    function getStatusInfo(uint256 tid) external view returns (ITaskStorage.StatusInfo memory) {
        return Storage().getStatusInfo(tid);
    }

    function getAddFileTaskProgress(uint256 tid) external view returns (ITaskStorage.AddFileTaskProgress memory) {
        return Storage().getAddFileTaskProgress(tid);
    }

    function acceptTask(address node, uint256 tid) external {
        require(Storage().exist(tid), contractName.concat(": task not exist"));

        ITaskStorage.TaskItem memory task = Storage().getTaskItem(tid);
        require(node == task.node, contractName.concat(": node have no this task"));

        ITaskStorage.Status status = Storage().getStatus(tid);
        if(ITaskStorage.Action.Add == task.action) {
            require(ITaskStorage.Status.Created == status, contractName.concat(": add file task status is not Created"));
        } else {
            require(ITaskStorage.Status.Created == status ||
                    ITaskStorage.Status.AcceptTimeout == status ||
                    ITaskStorage.Status.Timeout == status,
                contractName.concat(": delete file task status is not in [Created,AcceptTimeout,Timeout]"));
        }

        Storage().setStatusAndTime(tid, ITaskStorage.Status.Accepted, now);
    }

    function finishTask(uint256 tid) external { // TODO only Node
        require(Storage().exist(tid), contractName.concat(": task not exist"));

        ITaskStorage.Status status = Storage().getStatus(tid);
        require(ITaskStorage.Status.Accepted == status, contractName.concat(": task status is not Accepted"));

        Storage().setStatusAndTime(tid, ITaskStorage.Status.Finished, now);
    }

    function failTask(uint256 tid) external { // TODO only Node
        require(Storage().exist(tid), contractName.concat(": task not exist"));

        ITaskStorage.Action action = Storage().getAction(tid);
        require(ITaskStorage.Action.Add == action, contractName.concat(": only add file task can fail"));

        ITaskStorage.Status status = Storage().getStatus(tid);
        require(ITaskStorage.Status.Accepted == status, contractName.concat(": task status is not Accepted"));

        Storage().setStatusAndTime(tid, ITaskStorage.Status.Failed, now);
    }

    function TaskAcceptTimeout(uint256 tid) external { // TODO only Monitor
        require(Storage().exist(tid), contractName.concat(": task not exist"));
        ITaskStorage.Status status = Storage().getStatus(tid);
        require(ITaskStorage.Status.Created == status, contractName.concat(": task status is not Created"));
        Storage().setStatusAndTime(tid, ITaskStorage.Status.AcceptTimeout, now);
    }

    function TaskTimeout(uint256 tid) external { // TODO only Monitor
        require(Storage().exist(tid), contractName.concat(": task not exist"));
        ITaskStorage.Status status = Storage().getStatus(tid);
        require(ITaskStorage.Status.Accepted == status, contractName.concat(": task status is not Accepted"));
        Storage().setStatusAndTime(tid, ITaskStorage.Status.Timeout, now);
    }

    function reportAddFileProgressBySize(address addr, uint256 tid, uint256 size) external { // TODO only Node
        require(Storage().exist(tid), contractName.concat(": task not exist"));

        ITaskStorage.TaskItem memory task = Storage().getTaskItem(tid);
        require(addr == task.node, contractName.concat(": node have no this task"));

        ITaskStorage.Status status = Storage().getStatus(tid);
        require(ITaskStorage.Status.Accepted == status, contractName.concat(": task status is not Accepted"));

        Storage().setAddFileTaskProgressBySize(tid, now, size);
    }

    function reportAddFileProgressByPercentage(address addr, uint256 tid, uint256 percentage) external { // TODO only Node
        require(Storage().exist(tid), contractName.concat(": task not exist"));

        ITaskStorage.TaskItem memory task = Storage().getTaskItem(tid);
        require(addr == task.node, contractName.concat(": node have no this task"));

        ITaskStorage.Status status = Storage().getStatus(tid);
        require(ITaskStorage.Status.Accepted == status, contractName.concat(": task status is not Accepted"));

        Storage().setAddFileTaskProgressByPercentage(tid, now, percentage);
    }
}
