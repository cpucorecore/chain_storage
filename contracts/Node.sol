pragma solidity ^0.5.2;
pragma experimental ABIEncoderV2;

import "./base/Importable.sol";
import "./base/ExternalStorable.sol";
import "./interfaces/INode.sol";
import "./interfaces/storages/INodeStorage.sol";
import "./interfaces/ISetting.sol";
import "./lib/SafeMath.sol";
import "./interfaces/storages/ITaskStorage.sol";

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

    function register(address addr, uint256 space, string calldata ext) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        require(!Storage().exist(addr), contractName.concat(": node exist"));
        require(bytes(ext).length <= Setting().getMaxNodeExtLength(), contractName.concat(": ext too long"));
        require(space > 0, contractName.concat(": space must > 0"));

        Storage().newNode(addr, space, ext);

        emit NodeStatusChanged(addr, DefaultStatus, NodeRegistered);
    }

    function deRegister(address addr) external {
        // TODO node should delete cids and report the cids before deRegister
        mustAddress(CONTRACT_CHAIN_STORAGE);
        checkExist(addr);
        uint256 status = Storage().getStatus(addr);
        require(NodeRegistered == status ||
                NodeMaintain == status,
            contractName.concat(": can do deRegister only in [Registered/Maintain] status"));
        //TODO "N:WS" //Node:WrongStatus

        Storage().deleteNode(addr);

        emit NodeStatusChanged(addr, status, DefaultStatus);
    }

    function setExt(address addr, string calldata ext) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        checkExist(addr);
        require(bytes(ext).length <= Setting().getMaxNodeExtLength(), contractName.concat(": node ext too long"));
        Storage().setExt(addr, ext);
    }

    function changeSpace(address addr, uint256 space) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        checkExist(addr);
        require(space >= Storage().getStorageUsed(addr), contractName.concat(": can not little than storage used"));
        Storage().setStorageTotal(addr, space);
    }

    function online(address addr) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        checkExist(addr);

        uint256 status = Storage().getStatus(addr);
        require(NodeRegistered == status ||
                NodeMaintain == status ||
                NodeOffline == status,
            contractName.concat(": wrong status"));

        uint256 maxFinishedTid = Storage().getMaxFinishedTid(addr);
        uint256 nodeMaxTid = TaskStorage().getNodeMaxTid(addr);
        require(nodeMaxTid == maxFinishedTid, contractName.concat(": must finish all task"));

        Storage().setStatus(addr, NodeOnline);
        if(!Storage().isNodeOnline(addr)) {
            Storage().addOnlineNode(addr);
        }

        emit NodeStatusChanged(addr, status, NodeOnline);
    }

    function maintain(address addr) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        checkExist(addr);

        uint256 status = Storage().getStatus(addr);
        require(NodeOnline == status, contractName.concat(": wrong status"));

        Storage().setStatus(addr, NodeMaintain);

        if(Storage().isNodeOnline(addr)) {
            Storage().deleteOnlineNode(addr);
        }

        emit NodeStatusChanged(addr, status, NodeMaintain);
    }

    function checkExist(address addr) private view {
        require(Storage().exist(addr), contractName.concat(": node not exist"));
    }
}
