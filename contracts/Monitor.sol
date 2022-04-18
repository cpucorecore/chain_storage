pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import "./base/Importable.sol";
import "./base/ExternalStorable.sol";
import "./interfaces/IMonitor.sol";
import "./interfaces/storages/IMonitorStorage.sol";
import "./interfaces/ITask.sol";
import "./interfaces/ISetting.sol";
import "./interfaces/INode.sol";

contract Monitor is Importable, ExternalStorable, IMonitor {
    constructor(IResolver _resolver) public Importable(_resolver) {
        setContractName(CONTRACT_FILE);
        imports = [
        CONTRACT_SETTING,
        CONTRACT_FILE,
        CONTRACT_USER,
        CONTRACT_TASK
        ];
    }

    function Storage() private view returns (IMonitorStorage) {
        return IMonitorStorage(getStorage());
    }

    function Setting() private view returns (ISetting) {
        return ISetting(requireAddress(CONTRACT_SETTING));
    }

    function Node() private view returns (INode) {
        return INode(requireAddress(CONTRACT_NODE));
    }

    function register(address addr, string calldata ext) external {
        require(false == Storage().exist(addr), contractName.concat(": monitor exist"));
        require(bytes(ext).length <= 1024, contractName.concat(": ext too long, must<=1024"));
        Storage().newMonitor(addr, ext);
    }

    function deRegister(address addr) external {
        require(Storage().exist(addr), contractName.concat(": monitor not exist"));
        Storage().deleteMonitor(addr);
    }

    function online(address addr) external {
        require(Storage().exist(addr), contractName.concat(": monitor not exist"));
        IMonitorStorage.Status status = Storage().status(addr);
        require(IMonitorStorage.Status.Registered == status ||
                IMonitorStorage.Status.Maintain == status, contractName.concat(": wrong status"));
        Storage().setStatus(addr, IMonitorStorage.Status.Online);
    }

    function maintain(address addr) external {
        require(Storage().exist(addr), contractName.concat(": monitor not exist"));
        IMonitorStorage.Status status = Storage().status(addr);
        require(IMonitorStorage.Status.Online == status, contractName.concat(": wrong status"));
        Storage().setStatus(addr, IMonitorStorage.Status.Maintain);
    }

    function reportTaskTimeout(address addr, uint256 tid) external {
        require(Storage().exist(addr), contractName.concat(": monitor not exist"));
        IMonitorStorage.Status status = Storage().status(addr);
        require(IMonitorStorage.Status.Online == status, contractName.concat(": wrong status, must online"));
        Storage().addReport(addr, tid, now);
        Node().taskFailed(tid);
    }
}
