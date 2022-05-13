pragma solidity ^0.5.2;
pragma experimental ABIEncoderV2;

import "./base/Importable.sol";
import "./base/ExternalStorable.sol";
import "./interfaces/INode.sol";
import "./interfaces/storages/INodeStorage.sol";
import "./interfaces/ISetting.sol";
import "./lib/SafeMath.sol";
import "./interfaces/storages/ITaskStorage.sol";

// "N:e"        = "Node: exist"
// "N:etl"      = "Node: ext too long"
// "N:s0"       = "Node: storageTotal 0"
// "N:ws[RM]"   = "Node: wrong status, must [NodeRegistered/NodeMaintain]"
// "N:sts"       = "Node: storageTotal too small"

contract Node is Importable, ExternalStorable, INode {
    using SafeMath for uint256;

    event NodeStatusChanged(address indexed addr, uint256 from, uint256 to);

    constructor(IResolver _resolver) public Importable(_resolver) {
        setContractName(CONTRACT_NODE);
        imports = [
            CONTRACT_SETTING,
            CONTRACT_TASK_STORAGE
        ];
    }

    function Storage() private view returns (INodeStorage) {
        return INodeStorage(getStorage());
    }

    function Setting() private view returns (ISetting) {
        return ISetting(requireAddress(CONTRACT_SETTING));
    }

    function TaskStorage() private view returns (ITaskStorage) {
        return ITaskStorage(requireAddress(CONTRACT_TASK_STORAGE));
    }

    function register(address addr, uint256 storageTotal, string calldata ext) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);

        require(!Storage().exist(addr), "N:e");
        require(bytes(ext).length <= Setting().getMaxNodeExtLength(), "N:etl");
        require(storageTotal > 0, "N:s0");

        Storage().newNode(addr, storageTotal, ext);

        emit NodeStatusChanged(addr, DefaultStatus, NodeRegistered);
    }

    function deRegister(address addr) external {
        // TODO node should delete cids and report the cids before deRegister
        mustAddress(CONTRACT_CHAIN_STORAGE);

        nodeMustExist(addr);
        uint256 status = Storage().getStatus(addr);
        require(NodeRegistered == status || NodeMaintain == status, "N:ws[RM]");
        Storage().deleteNode(addr);

        emit NodeStatusChanged(addr, status, DefaultStatus);
    }

    function setExt(address addr, string calldata ext) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        nodeMustExist(addr);
        require(bytes(ext).length <= Setting().getMaxNodeExtLength(), "N:etl");
        Storage().setExt(addr, ext);
    }

    function setStorageTotal(address addr, uint256 storageTotal) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        nodeMustExist(addr);
        require(storageTotal >= Storage().getStorageUsed(addr), "N:tl");
        Storage().setStorageTotal(addr, storageTotal);
    }

    function online(address addr) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        nodeMustExist(addr);

        uint256 status = Storage().getStatus(addr);
        require(NodeRegistered == status ||
                NodeMaintain == status ||
                NodeOffline == status, "N:ws[RMO]");

        uint256 maxFinishedTid = Storage().getMaxFinishedTid(addr);
        uint256 nodeMaxTid = TaskStorage().getNodeMaxTid(addr);
        require(nodeMaxTid == maxFinishedTid, "N:tnf"); // task not finish

        Storage().setStatus(addr, NodeOnline);
        if(!Storage().isNodeOnline(addr)) {
            Storage().addOnlineNode(addr);
        }

        emit NodeStatusChanged(addr, status, NodeOnline);
    }

    function maintain(address addr) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        nodeMustExist(addr);

        uint256 status = Storage().getStatus(addr);
        require(NodeOnline == status, "N:ws[O]");

        Storage().setStatus(addr, NodeMaintain);

        if(Storage().isNodeOnline(addr)) {
            Storage().deleteOnlineNode(addr);
        }

        emit NodeStatusChanged(addr, status, NodeMaintain);
    }

    function nodeMustExist(address addr) private view {
        require(Storage().exist(addr), "N:ne"); // Node: not exist
    }
}
