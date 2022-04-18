pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import "./base/Importable.sol";
import "./base/ExternalStorable.sol";
import "./interfaces/ITask.sol";
import "./interfaces/storages/ITaskStorage.sol";

contract Node is Importable, ExternalStorable, ITask {
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

    function issueTaskAdd(string memory cid, string memory pid, uint256 size, uint256 duration) public returns(uint256) {
        // TODO config.monitor can issue task
        return Storage().newTask(cid, pid, size, ITaskStorage.Action.Add, block.number);
    }

    function issueTaskDelete(string memory cid, string memory pid, uint256 size) public returns(uint256) {
        // TODO config.monitor can issue task
        return Storage().newTask(cid, pid, size, ITaskStorage.Action.Delete, block.number);
    }

    function acceptTask(uint256 tid) external {
        require(Storage().exist(tid), contractName.concat(": task not exist"));
        require(ITaskStorage.Status.Created == Storage().status(tid), contractName.concat(": wrong task status"));

        Storage().setStatus(tid, ITaskStorage.Status.Accepted);
        Storage().setAcceptBlock(tid, block.number);
    }

    function finishTask(uint256 tid) public {
        require(Storage().exist(tid), contractName.concat(": task not exist"));
        require(ITaskStorage.Status.Accepted == Storage().status(tid), contractName.concat(": wrong task status"));

        Storage().setStatus(tid, ITaskStorage.Status.Finished);
        Storage().setEndBlock(tid, block.number);
    }

    function failTask(uint256 tid) public {
        // TODO config.monitor can fail task
    }

    function retryTask(uint256 tid) public {
    }
}
