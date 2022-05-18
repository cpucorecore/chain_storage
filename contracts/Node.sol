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

    function register(address nodeAddress, uint256 storageTotal, string calldata ext) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        require(!_Storage().exist(nodeAddress), "N:node exist");
        _Storage().newNode(nodeAddress, storageTotal, ext);
        emit NodeStatusChanged(nodeAddress, DefaultStatus, NodeRegistered);
    }

    function setExt(address nodeAddress, string calldata ext) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        _nodeMustExist(nodeAddress);
        _Storage().setExt(nodeAddress, ext);
    }

    function setStorageTotal(address nodeAddress, uint256 storageTotal) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        _nodeMustExist(nodeAddress);
        require(storageTotal >= _Storage().getStorageUsed(nodeAddress), "N:too small");
        _Storage().setStorageTotal(nodeAddress, storageTotal);
    }

    function deRegister(address nodeAddress) external {
        // TODO node should delete cids and report the cids before deRegister
        mustAddress(CONTRACT_CHAIN_STORAGE);

        _nodeMustExist(nodeAddress);
        uint256 status = _Storage().getStatus(nodeAddress);
        require(NodeRegistered == status || NodeMaintain == status, "N:wrong status must[RM]");
        _Storage().deleteNode(nodeAddress);

        emit NodeStatusChanged(nodeAddress, status, DefaultStatus);
    }

    function online(address nodeAddress) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        _nodeMustExist(nodeAddress);

        uint256 status = _Storage().getStatus(nodeAddress);
        require(NodeRegistered == status || NodeMaintain == status || NodeOffline == status, "N:wrong status[RMO]");

        uint256 maxFinishedTid = _Storage().getMaxFinishedTid(nodeAddress);
        uint256 nodeMaxTid = _Task().getNodeMaxTid(nodeAddress);
        require(nodeMaxTid == maxFinishedTid, "N:task not finish");

        _Storage().setStatus(nodeAddress, NodeOnline);
        _Storage().addOnlineNode(nodeAddress);

        emit NodeStatusChanged(nodeAddress, status, NodeOnline);
    }

    function maintain(address nodeAddress) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        _nodeMustExist(nodeAddress);

        uint256 status = _Storage().getStatus(nodeAddress);
        require(NodeOnline == status, "N:wrong status must[O]");

        _Storage().setStatus(nodeAddress, NodeMaintain);
        _Storage().deleteOnlineNode(nodeAddress);

        emit NodeStatusChanged(nodeAddress, status, NodeMaintain);
    }

    function addFile(address userAddress, string calldata cid) external {
        mustAddress(CONTRACT_FILE);

        uint256 replica = _Setting().getReplica();
        require(0 != replica, "N:replica is 0");

        (address[] memory nodeAddresses, bool success) = getStorage().selectNodes(replica);
        require(success, "N:no available node");

        for(uint256 i=0; i< nodeAddresses.length; i++) {
            _Task().issueTask(Add, userAddress, cid, nodeAddresses[i], false);
        }
    }

    function _nodeMustExist(address nodeAddress) private view {
        require(_Storage().exist(nodeAddress), "N:node not exist");
    }

    function finishTask(address nodeAddress, uint256 tid, uint256 size) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);

        (address userAddress, uint256 action, address _nodeAddress, bool noCallback, string memory cid) = _Task().getTask(tid);
        require(nodeAddress == _nodeAddress, "N:node have no this task");

        if(Add == action) {
            _File().onNodeAddFileFinish(nodeAddress, userAddress, cid, size);
            _Storage().useStorage(nodeAddress, size);
            _Storage().resetAddFileFailedCount(cid);
        } else if(Delete == action) {
            _Storage().freeStorage(nodeAddress, _File().getSize(cid)); // this must done before next code, for _File().getSize(cid) may 0
            if(!noCallback) {
                _File().onNodeDeleteFileFinish(nodeAddress, userAddress, cid);
            }
        }

        uint256 currentTid = _Storage().getMaxFinishedTid(nodeAddress);
        if(tid > currentTid) {
            _Storage().setMaxFinishedTid(nodeAddress, tid);
        }

        _Task().finishTask(tid);
    }

    function failTask(address nodeAddress, uint256 tid) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);

        (address userAddress, uint256 action, address _nodeAddress, , string memory cid) = _Task().getTask(tid);
        require(nodeAddress == _nodeAddress, "N:node have no this task");
        require(Add == action, "N:only Add can fail");

        uint256 maxAddFileFailedCount = _Setting().getMaxAddFileFailedCount();
        uint256 addFileFailedCount = _Storage().upAddFileFailedCount(cid);
        if(addFileFailedCount >= maxAddFileFailedCount) {
            _File().onAddFileFail(userAddress, cid);
            return;
        }

        if(Add == action) {
            _retryAddFileTask(userAddress, cid);
        }

        _Task().failTask(tid);
    }

    function reportAcceptTaskTimeout(uint256 tid) external {
        mustAddress(CONTRACT_MONITOR);

        (address userAddress, uint256 action, address nodeAddress, , string memory cid) = _Task().getTask(tid);
        _offline(nodeAddress);
        _Task().acceptTaskTimeout(tid);
        if(Add == action) {
            _retryAddFileTask(userAddress, cid);
        }
    }

    function reportTaskTimeout(uint256 tid) external {
        mustAddress(CONTRACT_MONITOR);

        (address userAddress, uint256 action, address nodeAddress, , string memory cid) = _Task().getTask(tid);
        _offline(nodeAddress);
        _Task().taskTimeout(tid);

        if(Add == action) {
            uint256 maxAddFileFailedCount = _Setting().getMaxAddFileFailedCount();
            uint256 addFileFailedCount = _Storage().upAddFileFailedCount(cid);
            if(addFileFailedCount >= maxAddFileFailedCount) {
                _File().onAddFileFail(userAddress, cid);
                return;
            }
            _retryAddFileTask(userAddress, cid);
        }
    }

    function _offline(address nodeAddress) private {
        mustAddress(CONTRACT_CHAIN_STORAGE);

        uint256 status = _Storage().getStatus(nodeAddress);
        require(NodeOnline == status, "N:wrong status must[O]");

        _Storage().setStatus(nodeAddress, NodeMaintain);
        _Storage().deleteOnlineNode(nodeAddress);

        emit NodeStatusChanged(nodeAddress, status, NodeMaintain);
    }

    function _retryAddFileTask(address userAddress, string memory cid) private {
        address nodeStorageAddress = getStorage();
        (address[] memory nodes, bool success) = nodeStorageAddress.selectNodes(1);
        require(success, "N:no available node");
        _Task().issueTask(Add, userAddress, cid, nodes[0], false);
    }
}
