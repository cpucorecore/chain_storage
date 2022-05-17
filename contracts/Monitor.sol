pragma solidity ^0.5.2;

import "./base/Importable.sol";
import "./base/ExternalStorable.sol";
import "./interfaces/IMonitor.sol";
import "./interfaces/storages/IMonitorStorage.sol";
import "./interfaces/ITask.sol";
import "./interfaces/INode.sol";

contract Monitor is Importable, ExternalStorable, IMonitor {
    event MonitorReport(address indexed addr, uint256 tid, uint256 reportType);

    constructor(IResolver _resolver) public Importable(_resolver) {
        setContractName(CONTRACT_MONITOR);
        imports = [
            CONTRACT_TASK,
            CONTRACT_NODE,
            CONTRACT_CHAIN_STORAGE
        ];
    }

    function _Storage() private view returns (IMonitorStorage) {
        return IMonitorStorage(getStorage());
    }

    function _Task() private view returns (ITask) {
        return ITask(requireAddress(CONTRACT_TASK));
    }

    function _Node() private view returns (INode) {
        return INode(requireAddress(CONTRACT_NODE));
    }

    function register(address addr, string calldata ext) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        require(!_Storage().exist(addr), "M:monitor exist");
        _Storage().newMonitor(addr, ext);
    }

    function deRegister(address addr) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        require(_Storage().exist(addr), "M:monitor not exist");
        require(MonitorMaintain == _Storage().getStatus(addr), "M:must in maintain");
        _Storage().deleteMonitor(addr);
    }

    function online(address addr) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        require(_Storage().exist(addr), "M:monitor not exist");
        uint256 status = _Storage().getStatus(addr);
        require(MonitorRegistered == status || MonitorMaintain == status, "M:wrong status");

        _Storage().setStatus(addr, MonitorOnline);
        _Storage().addOnlineMonitor(addr);

        if(MonitorRegistered == status) {
            uint256 currentTid = _Task().getCurrentTid();
            _Storage().setFirstOnlineTid(addr, currentTid);
        }
    }

    function maintain(address addr) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        require(_Storage().exist(addr), "M:monitor not exist");
        uint256 status = _Storage().getStatus(addr);
        require(MonitorOnline == status, "M:wrong status");
        _Storage().setStatus(addr, MonitorMaintain);
        _Storage().deleteOnlineMonitor(addr);
    }

    function resetCurrentTid(address addr, uint256 tid) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        uint256 firstOnlineTid = _Storage().getFirstOnlineTid(addr);
        if(tid<firstOnlineTid) {
            _Storage().setCurrentTid(addr, firstOnlineTid);
        } else {
            _Storage().setCurrentTid(addr, tid);
        }
    }

    function reportTaskAcceptTimeout(address addr, uint256 tid) public {
        // TODO: should verify the taskAcceptTimeout Report by this monitor
        mustAddress(CONTRACT_CHAIN_STORAGE);
        _Storage().addReport(addr, tid, ReportAcceptTimeout, now);
        _Node().reportAcceptTaskTimeout(addr, tid);
        emit MonitorReport(addr, tid, ReportAcceptTimeout);
    }

    function reportTaskTimeout(address addr, uint256 tid) public {
        // TODO: Node should verify the taskTimeout Report by this monitor
        mustAddress(CONTRACT_CHAIN_STORAGE);
        _Storage().addReport(addr, tid, ReportTimeout, now);
        _Node().reportTaskTimeout(addr, tid);
        emit MonitorReport(addr, tid, ReportTimeout);
    }

    function _saveCurrentTid(address addr, uint256 tid) private {
        uint256 currentTid = _Storage().getCurrentTid(addr);
        if(tid > currentTid) {
            _Storage().setCurrentTid(addr, tid);
        }
    }
}
