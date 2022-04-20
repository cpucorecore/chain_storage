pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import "./base/Importable.sol";
import "./base/ExternalStorable.sol";
import "./interfaces/INode.sol";
import "./interfaces/storages/INodeStorage.sol";
import "./interfaces/ITask.sol";
import "./interfaces/ISetting.sol";

contract Node is Importable, ExternalStorable, INode {
    constructor(IResolver _resolver) public Importable(_resolver) {
        setContractName(CONTRACT_FILE);
        imports = [
        CONTRACT_SETTING,
        CONTRACT_FILE,
        CONTRACT_USER,
        CONTRACT_TASK
        ];
    }

    function Storage() private view returns (INodeStorage) {
        return INodeStorage(getStorage());
    }

    function Setting() private view returns (ISetting) {
        return ISetting(requireAddress(CONTRACT_SETTING));
    }

    function Task() private view returns (ITask) {
        return ITask(requireAddress(CONTRACT_TASK));
    }

    function register(address addr, string calldata pid, uint256 space, string calldata ext) external {
        require(false == Storage().exist(addr), contractName.concat(": node exist"));
        Storage().newNode(addr, pid, space, ext);
    }

    function ext(address addr) external returns (string memory) {
        check(addr);
        return Storage().ext(addr);
    }

    function updateExt(address addr, string calldata ext) external {
        check(addr);
        require(bytes(ext).length <= 1024, contractName.concat(": ext too long, max lenght[1024]"));
        Storage().setExt(addr, ext);
    }

    function deRegister(address addr) public {
        check(addr);
        Storage().deleteNode(addr);
    }

    function online(address addr) external {
        check(addr);

        INodeStorage.Status status = Storage().status(addr);
        require(INodeStorage.Status.Registered == status ||
                INodeStorage.Status.Maintain == status ||
                INodeStorage.Status.Offline == status,
            contractName.concat(": wrong status"));

        INodeStorage.BlockInfo memory blockInfo = Storage().blockInfo(addr);
        require(blockInfo.currentBlock == blockInfo.targetBlock, contractName.concat("must finish all task"));

        Storage().setStatus(addr, INodeStorage.Status.Online);
    }

    function offline(address addr) public {
        check(addr);

        INodeStorage.Status status = Storage().status(addr);
        require(INodeStorage.Status.Online == status, contractName.concat(": wrong status"));

        Storage().setStatus(addr, INodeStorage.Status.Offline);
    }

    function maintain(address addr) public {
        check(addr);

        INodeStorage.Status status = Storage().status(addr);
        require(INodeStorage.Status.Online == status, contractName.concat(": wrong status"));

        Storage().setStatus(addr, INodeStorage.Status.Maintain);
    }

    function addFile(string memory cid, uint256 size, uint256 duration) public {
        address[] memory addrs = selectNodes(size, Setting().replica());
        require(addrs.length > 0, contractName.concat(": no available node"));

        for(uint256 i=0; i<addrs.length; i++) {
            Task().issueTaskAdd(cid, addrs[i], size, duration);
        }
    }

    function pid(address addr) public view returns (string memory) {
        return Storage().pid(addr);
    }

    function nodeAddresses(uint256 pageSize, uint256 pageNumber) public view returns (address[] memory, Paging.Page memory) {
        return Storage().nodeAddresses(pageSize, pageNumber);
    }

    function cids(address addr, uint256 pageSize, uint256 pageNumber) external view returns (string[] memory, Paging.Page memory) {
        return Storage().cids(addr, pageSize, pageNumber);
    }

    function starve(address addr) public view returns (uint256) {
        return Storage().starve(addr);
    }

    function taskFinished(uint256 tid) public {

    }

    function taskFailed(uint256 tid) public {

    }

    function taskAcceptTimeout(uint256 tid) external {
        ITaskStorage.TaskItem memory task = Task().task(tid);
        if(ITaskStorage.Action.Add == task.action) {
            Storage().upTaskAddAcceptTimeoutCount(task.node);
            if(Storage().totalTaskTimeoutCount(task.node) > Setting().maxTimeout()) {
                offline(task.node);
            }

            addFile(task.cid, task.size, task.duration);
        } else if(ITaskStorage.Action.Delete == task.action) {
            Storage().upTaskDeleteAcceptTimeoutCount(task.node);
        }
    }

    function taskTimeout(uint256 tid) external {
        ITaskStorage.TaskItem memory task = Task().task(tid);
    }

    function selectNodes(uint256 size, uint256 count) private returns (address[] memory) {
        address[] memory onlineNodeAddresses;
        Paging.Page memory page;
        (onlineNodeAddresses, page) = Storage().onlineNodeAddresses(50, 1);
        if(onlineNodeAddresses.length <= count) {
            return onlineNodeAddresses;
        } else {
            address[] memory nodes = new address[](count);
            for(uint256 i=0; i<count; i++) {
                if(Storage().freeSpace(onlineNodeAddresses[i]) >= size) {
                    nodes[i] = onlineNodeAddresses[i];
                }
            }
            return nodes;
        }

        // TODO select by socre
    }

    function feedNode(uint256 food) private {

    }

    function check(address addr) private {
        require(Storage().exist(addr), contractName.concat(": node not exist"));
    }
}