pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import "./base/Importable.sol";
import "./base/ExternalStorable.sol";
import "./interfaces/ITask.sol";
import "./interfaces/storages/ITaskStorage.sol";

contract Task is Importable, ExternalStorable, ITask {
    event TaskIssued(uint256 indexed tid, string cid, address node, ITaskStorage.Action action, uint256 size, uint256 duration);

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

    function issueTaskAdd(string calldata cid, address node, uint256 size, uint256 duration) external {
        uint256 tid = Storage().newTask(cid, node, size, ITaskStorage.Action.Add, block.number);
        emit TaskIssued(tid, cid, node, ITaskStorage.Action.Add, size, duration);
    }

    function issueTaskDelete(string calldata cid, address node, uint256 size) external {
        uint256 tid = Storage().newTask(cid, node, size, ITaskStorage.Action.Delete, block.number);
        emit TaskIssued(tid, cid, node, ITaskStorage.Action.Delete, size, 0);
    }

    function acceptTask(uint256 tid) external {
        require(Storage().exist(tid), contractName.concat(": task not exist"));
        require(ITaskStorage.Status.Created == Storage().status(tid), contractName.concat(": wrong task status"));

        Storage().setStatus(tid, ITaskStorage.Status.Accepted);
        Storage().setAcceptedBlock(tid, block.number);
    }

    function finishTask(uint256 tid) public {
        require(Storage().exist(tid), contractName.concat(": task not exist"));
        require(ITaskStorage.Status.Accepted == Storage().status(tid), contractName.concat(": wrong task status"));

        Storage().setStatus(tid, ITaskStorage.Status.Finished);
        Storage().setFinishedBlock(tid, block.number);
    }

    function failTask(uint256 tid) public {
        // TODO config.monitor can fail task
    }

    function retryTask(uint256 tid) public {
    }
}
