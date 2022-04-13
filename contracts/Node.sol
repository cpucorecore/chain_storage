pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import "./base/Importable.sol";
import "./base/ExternalStorable.sol";
import "./interfaces/INode.sol";
import "./interfaces/storages/INodeStorage.sol";

contract Node is Importable, ExternalStorable, INode {
    constructor(IResolver _resolver) public Importable(_resolver) {
        setContractName(CONTRACT_FILE);
        imports = [
        CONTRACT_FILE,
        CONTRACT_USER,
        CONTRACT_TASK
        ];
    }

    function Storage() private view returns(INodeStorage) {
        return INodeStorage(getStorage());
    }

    function register(string memory pid, uint256 storageSpace) public {
        require(false == Storage().exist(pid), contractName.concat(": node not exist, pid-", pid));
        require(Storage().chainAccount(pid) == msg.sender, contractName.concat(": no auth"));
        Storage().newNode(pid, msg.sender, storageSpace);
    }

    function deRegister(string memory pid) public {
        check(pid);
        Storage().deleteNode(pid);
    }

    function online(string memory pid) public {
        check(pid);
        Storage().online(pid);
    }

    function offline(string memory pid) public {
        check(pid);
        Storage().offline(pid);
    }

    function maintain(string memory pid) public {
        check(pid);
        Storage().maintain(pid);
    }

    function addFile(string memory cid, uint256 size, uint256 duration) public {
        string[] memory tmpNodes = selectNodes(size, 3); // TODO 3 --> read from config
        require(tmpNodes.length > 0, contractName.concat(": no available node"));
        for(uint256 i=0; i<tmpNodes.length; i++) {
            // Task().issueAddTask(pid, cid, size, duration);
        }
    }

    function pids() public view returns(string[] memory) {// TODO page query
        return Storage().pids();
    }

    function starve(string memory pid) public view returns(uint256) {
        return Storage().starve(pid);
    }

    function taskFinished(uint256 tid) public {

    }

    function taskFailed(uint256 tid) public {

    }

    function selectNodes(uint256 size, uint256 count) private returns(string[] memory) {

    }

    function feedNode(uint256 food) private {

    }

    // private functions
    function check(string memory pid) private {
        require(Storage().exist(pid), contractName.concat(": node not exist, pid-", pid));
        require(Storage().chainAccount(pid) == msg.sender, contractName.concat(": no auth"));
    }
}