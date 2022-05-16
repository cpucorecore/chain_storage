pragma solidity ^0.5.2;
pragma experimental ABIEncoderV2;

import "./base/Importable.sol";
import "./base/ExternalStorable.sol";
import "./interfaces/ITask.sol";
import "./interfaces/storages/ITaskStorage.sol";
import "./lib/StatusTypes.sol";

contract Task is Importable, ExternalStorable, ITask {
    event TaskIssued(address indexed node, uint256 indexed tid);
    event TaskStatusChanged(uint256 tid, address indexed node, uint256 action, uint256 from, uint256 to);

    bytes32[] private ISSUEABLE_CONTRACTS = [CONTRACT_NODE, CONTRACT_FILE];

    constructor(IResolver _resolver) public Importable(_resolver) {
        setContractName(CONTRACT_TASK);
    }

    function Storage() private view returns(ITaskStorage) {
        return ITaskStorage(getStorage());
    }

    function issueTask(uint256 action, address owner, string calldata cid, address node) external returns (uint256) {
        mustContainAddress(ISSUEABLE_CONTRACTS);
        uint256 tid = Storage().newTask(owner, action, cid, node);
        emit TaskIssued(node, tid);
        emit TaskStatusChanged(tid, node, action, DefaultStatus, TaskCreated);
        return tid;
    }

    function acceptTask(address node, uint256 tid) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        checkTaskExist(tid);

        address taskNode = Storage().getNode(tid);
        require(node == taskNode, contractName.concat(": node have no this task"));

        uint256 action = Storage().getAction(tid);
        uint256 status = Storage().getStatus(tid);
        if(Add == action) {
            require(TaskCreated == status, contractName.concat(": add file task status is not Created"));
        } else {
            require(TaskCreated == status ||
                    TaskAcceptTimeout == status ||
                    TaskTimeout == status,
                contractName.concat(": delete file task status is not in [Created,AcceptTimeout,Timeout]"));
        }

        Storage().setStatusAndTime(tid, TaskAccepted, now);
        emit TaskStatusChanged(tid, node, action, status, TaskAccepted);
    }

    function finishTask(uint256 tid) external {
        mustAddress(CONTRACT_NODE);
        checkTaskExist(tid);

        uint256 status = Storage().getStatus(tid);
        address node = Storage().getNode(tid);
        uint256 action = Storage().getAction(tid);
        require(TaskAccepted == status, contractName.concat(": task status is not Accepted"));

        Storage().setStatusAndTime(tid, TaskFinished, now);
        emit TaskStatusChanged(tid, node, action, status, TaskFinished);
    }

    function failTask(uint256 tid) external {
        mustAddress(CONTRACT_NODE);
        checkTaskExist(tid);

        address node = Storage().getNode(tid);
        uint256 action = Storage().getAction(tid);
        require(Add == action, contractName.concat(": only add file task can fail"));

        uint256 status = Storage().getStatus(tid);
        require(TaskAccepted == status, contractName.concat(": task status is not Accepted"));

        Storage().setStatusAndTime(tid, TaskFailed, now);
        emit TaskStatusChanged(tid, node, action, status, TaskFailed);
    }

    function acceptTaskTimeout(uint256 tid) external {
        mustAddress(CONTRACT_NODE);
        checkTaskExist(tid);

        address node = Storage().getNode(tid);
        uint256 action = Storage().getAction(tid);
        uint256 status = Storage().getStatus(tid);
        require(TaskCreated == status, contractName.concat(": task status is not Created"));

        Storage().setStatusAndTime(tid, TaskAcceptTimeout, now);
        emit TaskStatusChanged(tid, node, action, status, TaskFailed);
    }

    function taskTimeout(uint256 tid) external {
        mustAddress(CONTRACT_NODE);
        checkTaskExist(tid);

        uint256 status = Storage().getStatus(tid);
        address node = Storage().getNode(tid);
        uint256 action = Storage().getAction(tid);
        require(TaskAccepted == status, contractName.concat(": task status is not Accepted"));

        Storage().setStatusAndTime(tid, TaskTimeout, now);

        emit TaskStatusChanged(tid, node, action, status, TaskTimeout);
    }

    function reportAddFileProgressBySize(address addr, uint256 tid, uint256 size) external { // TODO
        mustAddress(CONTRACT_NODE);
        checkTaskExist(tid);

        address node = Storage().getNode(tid);
        require(addr == node, contractName.concat(": node have no this task"));

        uint256 status = Storage().getStatus(tid);
        require(TaskAccepted == status, contractName.concat(": task status is not Accepted"));

        Storage().setAddFileTaskProgressBySize(tid, now, size);
    }

    function reportAddFileProgressByPercentage(address addr, uint256 tid, uint256 percentage) external { // TODO
        mustAddress(CONTRACT_NODE);
        checkTaskExist(tid);

        address node = Storage().getNode(tid);
        require(addr == node, contractName.concat(": node have no this task"));

        uint256 status = Storage().getStatus(tid);
        require(TaskAccepted == status, contractName.concat(": task status is not Accepted"));

        Storage().setAddFileTaskProgressByPercentage(tid, now, percentage);
    }

    function checkTaskExist(uint256 tid) private view {
        require(Storage().exist(tid), contractName.concat(": task not exist"));
    }
}
