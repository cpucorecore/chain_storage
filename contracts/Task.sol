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
        return Storage().newTask(cid, pid, size, ITaskStorage.Action.Add);
    }

    function issueTaskDelete(string memory cid, string memory pid, uint256 size) public returns(uint256) {
        // TODO config.monitor can issue task
        return Storage().newTask(cid, pid, size, ITaskStorage.Action.Delete);
    }

    function finishTask(uint256 tid) public {
    }

    function failTask(uint256 tid) public {
        // TODO config.monitor can fail task
    }

    function retryTask(uint256 tid) public {
    }
}
