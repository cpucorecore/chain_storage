pragma solidity ^0.5.2;
pragma experimental ABIEncoderV2;

import "./base/Importable.sol";
import "./base/ExternalStorable.sol";
import "./interfaces/INode.sol";
import "./interfaces/storages/INodeStorage.sol";
import "./interfaces/ITask.sol";
import "./interfaces/ISetting.sol";

contract Node is Importable, ExternalStorable, INode {
    using SafeMath for uint256;

    constructor(IResolver _resolver) public Importable(_resolver) {
        setContractName(CONTRACT_NODE);
        imports = [
            CONTRACT_SETTING,
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

    function register(address addr, uint256 space, string calldata ext) external onlyAddress(CONTRACT_CHAIN_STORAGE) {
        require(!Storage().exist(addr), contractName.concat(": node exist"));
        require(bytes(ext).length <= Setting().getMaxNodeExtLength(), contractName.concat(": ext too long"));
        require(space > 0, contractName.concat(": space must > 0"));

        Storage().newNode(addr, space, ext);
    }

    function deRegister(address addr) external onlyAddress(CONTRACT_CHAIN_STORAGE) {
        checkExist(addr);
        require(0 == Storage().getNodeCidsNumber(addr), contractName.concat(": files not empty"));
        INodeStorage.Status status = Storage().getStatus(addr);
        require(INodeStorage.Status.Registered == status ||
                INodeStorage.Status.Maintain == status,
            contractName.concat(": can do deRegister only in [Registered/Maintain] status"));

        Storage().deleteNode(addr);
    }

    function setExt(address addr, string calldata ext) external onlyAddress(CONTRACT_CHAIN_STORAGE) {
        checkExist(addr);
        require(bytes(ext).length <= Setting().getMaxNodeExtLength(), contractName.concat(": node ext too long"));
        Storage().setExt(addr, ext);
    }

    function changeSpace(address addr, uint256 space) external onlyAddress(CONTRACT_CHAIN_STORAGE) {
        checkExist(addr);
        require(space >= Storage().getStorageUsed(addr), contractName.concat(": can not little than storage used"));
        Storage().setStorageTotal(addr, space);
    }

    function online(address addr) external onlyAddress(CONTRACT_CHAIN_STORAGE) {
        checkExist(addr);

        INodeStorage.Status status = Storage().getStatus(addr);
        require(INodeStorage.Status.Registered == status ||
                INodeStorage.Status.Maintain == status ||
                INodeStorage.Status.Offline == status,
            contractName.concat(": wrong status"));

        uint256 maxFinishedTid = Storage().getMaxFinishedTid(addr);
        uint256 nodeMaxTid = Task().getNodeMaxTid(addr);
        require(nodeMaxTid == maxFinishedTid, contractName.concat(": must finish all task"));

        Storage().setStatus(addr, INodeStorage.Status.Online);
        if(!Storage().isNodeOnline(addr)) {
            Storage().addOnlineNode(addr);
        }
    }

    function maintain(address addr) external onlyAddress(CONTRACT_CHAIN_STORAGE) {
        checkExist(addr);

        INodeStorage.Status status = Storage().getStatus(addr);
        require(INodeStorage.Status.Online == status, contractName.concat(": wrong status"));

        Storage().setStatus(addr, INodeStorage.Status.Maintain);
        uint256 maintainCount = Storage().getMaintainCount(addr);
        Storage().setMaintainCount(addr, maintainCount.add(1));

        if(Storage().isNodeOnline(addr)) {
            Storage().deleteOnlineNode(addr);
        }
    }

    function checkExist(address addr) private view {
        require(Storage().exist(addr), contractName.concat(": node not exist"));
    }
}
