pragma solidity ^0.5.2;
pragma experimental ABIEncoderV2; // use this can make contract size smaller

import "./base/Importable.sol";
import "./base/ExternalStorable.sol";
import "./interfaces/INode.sol";
import "./interfaces/storages/INodeStorage.sol";
import "./interfaces/ISetting.sol";
import "./interfaces/ITask.sol";
import "./interfaces/IFile.sol";
import "./lib/NodeSelector.sol";

contract Node is Importable, ExternalStorable, INode {
    using NodeSelector for address;

    event NodeStatusChanged(address indexed addr, uint256 from, uint256 to);

    constructor(IResolver _resolver) public Importable(_resolver) {
        setContractName(CONTRACT_NODE);
        imports = [
            CONTRACT_SETTING,
            CONTRACT_TASK,
            CONTRACT_FILE,
            CONTRACT_CHAIN_STORAGE
        ];
    }

    function _Storage() private view returns (INodeStorage) {
        return INodeStorage(getStorage());
    }

    function _Setting() private view returns (ISetting) {
        return ISetting(requireAddress(CONTRACT_SETTING));
    }

    function _Task() private view returns (ITask) {
        return ITask(requireAddress(CONTRACT_TASK));
    }

    function _File() private view returns (IFile) {
        return IFile(requireAddress(CONTRACT_FILE));
    }

    function register(address addr, uint256 storageTotal, string calldata ext) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        require(!_Storage().exist(addr), "N:node exist");
        _Storage().newNode(addr, storageTotal, ext);
        emit NodeStatusChanged(addr, DefaultStatus, NodeRegistered);
    }

    function setExt(address addr, string calldata ext) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        _nodeMustExist(addr);
        _Storage().setExt(addr, ext);
    }

    function setStorageTotal(address addr, uint256 storageTotal) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        _nodeMustExist(addr);
        require(storageTotal >= _Storage().getStorageUsed(addr), "N:too small");
        _Storage().setStorageTotal(addr, storageTotal);
    }

    function deRegister(address addr) external {
        // TODO node should delete cids and report the cids before deRegister
        mustAddress(CONTRACT_CHAIN_STORAGE);

        _nodeMustExist(addr);
        uint256 status = _Storage().getStatus(addr);
        require(NodeRegistered == status || NodeMaintain == status, "N:wrong status must[RM]");
        _Storage().deleteNode(addr);

        emit NodeStatusChanged(addr, status, DefaultStatus);
    }

    function online(address addr) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        _nodeMustExist(addr);

        uint256 status = _Storage().getStatus(addr);
        require(NodeRegistered == status || NodeMaintain == status || NodeOffline == status, "N:wrong status[RMO]");

        uint256 maxFinishedTid = _Storage().getMaxFinishedTid(addr);
        uint256 nodeMaxTid = _Task().getNodeMaxTid(addr);
        require(nodeMaxTid == maxFinishedTid, "N:task not finish");

        _Storage().setStatus(addr, NodeOnline);
        _Storage().addOnlineNode(addr);

        emit NodeStatusChanged(addr, status, NodeOnline);
    }

    function maintain(address addr) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        _nodeMustExist(addr);

        uint256 status = _Storage().getStatus(addr);
        require(NodeOnline == status, "N:wrong status must[O]");

        _Storage().setStatus(addr, NodeMaintain);
        _Storage().deleteOnlineNode(addr);

        emit NodeStatusChanged(addr, status, NodeMaintain);
    }

    function addFile(address owner, string calldata cid) external {
        mustAddress(CONTRACT_FILE);

        uint256 replica = _Setting().getReplica();
        require(0 != replica, "N:replica is 0");

        address nodeStorageAddr = getStorage();
        address[] memory nodeAddrs;
        bool success;
        (nodeAddrs, success) = nodeStorageAddr.selectNodes(replica);
        require(success, "N:no available node");

        for(uint256 i=0; i<nodeAddrs.length; i++) {
            _Task().issueTask(Add, owner, cid, nodeAddrs[i]);
        }
    }

    function _nodeMustExist(address addr) private view {
        require(_Storage().exist(addr), "N:node not exist");
    }

    function finishTask(address addr, uint256 tid, uint256 size) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);

        (address owner, uint256 action, address node, string memory cid) = _Task().getTask(tid);
        require(addr == node, "N:node have no this task");

        if(Add == action) {
            _File().onNodeAddFileFinish(node, owner, cid, size);
            _Storage().useStorage(node, size);
            _Storage().resetAddFileFailedCount(cid);
        } else if(Delete == action) {
            _File().onNodeDeleteFileFinish(node, owner, cid);
            _Storage().freeStorage(node, _File().getSize(cid));
        }

        uint256 currentTid = _Storage().getMaxFinishedTid(addr);
        if(tid > currentTid) {
            _Storage().setMaxFinishedTid(addr, tid);
        }

        _Task().finishTask(tid);
    }

    function failTask(address addr, uint256 tid) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);

        (address owner, uint256 action, address node, string memory cid) = _Task().getTask(tid);
        require(addr == node, "N:node have no this task");
        require(Add == action, "N:only Add can fail");

        uint256 maxAddFileFailedCount = _Setting().getMaxAddFileFailedCount();
        uint256 addFileFailedCount = _Storage().upAddFileFailedCount(cid);
        if(addFileFailedCount >= maxAddFileFailedCount) {
            _File().onAddFileFail(owner, cid);
            return;
        }

        if(Add == action) {
            _retryAddFileTask(owner, cid);
        }

        _Task().failTask(tid);
    }

    function reportAcceptTaskTimeout(uint256 tid) external {
        mustAddress(CONTRACT_MONITOR);

        (, uint256 action, address node, string memory cid) = _Task().getTask(tid);
        _offline(node);
        _Task().acceptTaskTimeout(tid);
        if(Add == action) {
            _retryAddFileTask(owner, cid);
        }
    }

    function reportTaskTimeout(uint256 tid) external {
        mustAddress(CONTRACT_MONITOR);

        (address owner, uint256 action, address node, string memory cid) = _Task().getTask(tid);
        _offline(node);
        _Task().taskTimeout(tid);

        if(Add == action) {
            uint256 maxAddFileFailedCount = _Setting().getMaxAddFileFailedCount();
            uint256 addFileFailedCount = _Storage().upAddFileFailedCount(cid);
            if(addFileFailedCount >= maxAddFileFailedCount) {
                _File().onAddFileFail(owner, cid);
                return;
            }
            _retryAddFileTask(owner, cid);
        }
    }

    function _offline(address addr) private {
        mustAddress(CONTRACT_CHAIN_STORAGE);

        uint256 status = _Storage().getStatus(addr);
        require(NodeOnline == status, "N:wrong status must[O]");

        _Storage().setStatus(addr, NodeMaintain);
        _Storage().deleteOnlineNode(addr);

        emit NodeStatusChanged(addr, status, NodeMaintain);
    }

    function _retryAddFileTask(address owner, string memory cid) private {
        address nodeStorageAddr = getStorage();
        (address[] memory nodes, bool success) = nodeStorageAddr.selectNodes(1);
        require(success, "N:no available node");
        _Task().issueTask(Add, owner, cid, nodes[0]);
    }
}
