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

    function Storage() private view returns (INodeStorage) {
        return INodeStorage(getStorage());
    }

    function register(address addr, string memory pid, uint256 storageSpace) public {
        require(false == Storage().exist(addr), contractName.concat(": node exist"));
        require(Storage().chainAccount(pid) == msg.sender, contractName.concat(": no auth"));
        Storage().newNode(pid, msg.sender, storageSpace);
    }

    function deRegister(address addr) public {
        check(addr);
        Storage().deleteNode(addr);
    }

    function online(address addr) public {
        check(addr);
        Storage().setStatus(addr, INodeStorage.Status.Online);
    }

    function offline(address addr) public {
        check(addr);
        Storage().setStatus(addr, INodeStorage.Status.Offline);
    }

    function maintain(address addr) public {
        check(addr);
        Storage().setStatus(addr, INodeStorage.Status.Maintain);
    }

    function addFile(string memory cid, uint256 size, uint256 duration) public {
        string[] memory nodes = selectNodes(size, 3); // TODO 3 --> read from config
        require(nodes.length > 0, contractName.concat(": no available node"));
        for(uint256 i=0; i< nodes.length; i++) {
            // Task().issueAddTask(pid, cid, size, duration);
        }
    }

    function pids() public view returns (string[] memory) {// TODO page query
        return Storage().pids();
    }

    function starve(address addr) public view returns (uint256) {
        return Storage().starve(addr);
    }

    function taskFinished(uint256 tid) public {

    }

    function taskFailed(uint256 tid) public {

    }

    function selectNodes(uint256 size, uint256 count) private returns (string[] memory) {

    }

    function feedNode(uint256 food) private {

    }

    function check(address addr) private {
        require(Storage().exist(addr), contractName.concat(": node not exist"));
    }
}