pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import "./base/Importable.sol";
import "./base/ExternalStorable.sol";
import "./interfaces/ITask.sol";
import "./interfaces/storages/ITaskStorage.sol";

contract Task is Importable, ExternalStorable, ITask {
    event TaskIssued(uint256 indexed tid, address node);

    constructor(IResolver _resolver) public Importable(_resolver) {
        setContractName(CONTRACT_FILE);
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
        uint256 tid = Storage().newTask(owner, action, cid, size, node, now);
        emit TaskIssued(tid, cid, node, ITaskStorage.Action.Add, size, duration);
        return tid;
    }

    function getTaskItem(uint256 tid) external view returns (ITaskStorage.TaskItem memory) {
        return Storage().getTaskItem(tid);
    }

    function getStatusInfo(uint256 tid) external view returns (ITaskStorage.StatusInfo memory) {
        return Storage().getStatusInfo(tid);
    }

    function getAddFileTaskProgress(uint256 tid) external view returns (ITaskStorage.AddFileTaskProgress memory) {
        return Storage().getAddFileTaskProgress(tid);
    }

    function acceptTask(uint256 tid) external {
        require(Storage().exist(tid), contractName.concat(": task not exist"));
        ITaskStorage.Status status = Storage().getStatus(tid);
        require(ITaskStorage.Status.Created == status, contractName.concat(": task status is not Created"));
        Storage().setStatusAndTime(tid, ITaskStorage.Status.Accepted, now);
    }

    function finishTask(uint256 tid) external {
        require(Storage().exist(tid), contractName.concat(": task not exist"));
        ITaskStorage.Status status = Storage().getStatus(tid);
        require(ITaskStorage.Status.Accepted == status, contractName.concat(": task status is not Accepted"));
        Storage().setStatusAndTime(tid, ITaskStorage.Status.Finished, now);
    }

    function failTask(uint256 tid) external {
        require(Storage().exist(tid), contractName.concat(": task not exist"));
        ITaskStorage.Status status = Storage().getStatus(tid);
        require(ITaskStorage.Status.Accepted == status, contractName.concat(": task status is not Accepted"));
        Storage().setStatusAndTime(tid, ITaskStorage.Status.Failed, now);
    }

    function TaskAcceptTimeout(uint256 tid) external {
        require(Storage().exist(tid), contractName.concat(": task not exist"));
        ITaskStorage.Status status = Storage().getStatus(tid);
        require(ITaskStorage.Status.Created == status, contractName.concat(": task status is not Created"));
        Storage().setStatusAndTime(tid, ITaskStorage.Status.AcceptTimeout, now);
    }

    function TaskTimeout(uint256 tid) external {
        require(Storage().exist(tid), contractName.concat(": task not exist"));
        ITaskStorage.Status status = Storage().getStatus(tid);
        require(ITaskStorage.Status.Accepted == status, contractName.concat(": task status is not Accepted"));
        Storage().setStatusAndTime(tid, ITaskStorage.Status.Timeout, now);
    }

    function reportAddFileProgress(uint256 tid, uint256 size) external {
        require(Storage().exist(tid), contractName.concat(": task not exist"));
        ITaskStorage.Status status = Storage().getStatus(tid);
        require(ITaskStorage.Status.Accepted == status, contractName.concat(": task status is not Accepted"));
        Storage().setAddFileTaskProgress(tid, now, size);
    }
}
