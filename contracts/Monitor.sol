pragma solidity ^0.5.2;

import "./base/Importable.sol";
import "./base/ExternalStorable.sol";
import "./interfaces/IMonitor.sol";
import "./interfaces/storages/IMonitorStorage.sol";
import "./interfaces/ITask.sol";
import "./interfaces/INode.sol";

contract Monitor is Importable, ExternalStorable, IMonitor {
    event MonitorReport(address indexed monitorAddress, uint256 tid, uint256 reportType);

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

    function register(address monitorAddress, string calldata ext) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        require(!_Storage().exist(monitorAddress), "M:monitor exist");
        _Storage().newMonitor(monitorAddress, ext);
    }

    function deRegister(address monitorAddress) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        require(_Storage().exist(monitorAddress), "M:monitor not exist");
        require(MonitorMaintain == _Storage().getStatus(monitorAddress), "M:status must be maintain");
        _Storage().deleteMonitor(monitorAddress);
    }

    function online(address monitorAddress) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        require(_Storage().exist(monitorAddress), "M:monitor not exist");
        uint256 status = _Storage().getStatus(monitorAddress);
        require(MonitorRegistered == status || MonitorMaintain == status, "M:wrong status");

        _Storage().setStatus(monitorAddress, MonitorOnline);
        _Storage().addOnlineMonitor(monitorAddress);

        if(MonitorRegistered == status) {
            uint256 currentTid = _Task().getCurrentTid();
            _Storage().setFirstOnlineTid(monitorAddress, currentTid);
        }
    }

    function maintain(address monitorAddress) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        require(_Storage().exist(monitorAddress), "M:monitor not exist");
        uint256 status = _Storage().getStatus(monitorAddress);
        require(MonitorOnline == status, "M:wrong status");
        _Storage().setStatus(monitorAddress, MonitorMaintain);
        _Storage().deleteOnlineMonitor(monitorAddress);
    }

    function resetCurrentTid(address monitorAddress, uint256 tid) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        uint256 firstOnlineTid = _Storage().getFirstOnlineTid(monitorAddress);
        if(tid<firstOnlineTid) {
            _Storage().setCurrentTid(monitorAddress, firstOnlineTid);
        } else {
            _Storage().setCurrentTid(monitorAddress, tid);
        }
    }

    function reportTaskAcceptTimeout(address monitorAddress, uint256 tid) public {
        // TODO: should verify the taskAcceptTimeout Report by this monitor
        mustAddress(CONTRACT_CHAIN_STORAGE);
        _Storage().addReport(monitorAddress, tid, ReportAcceptTimeout, now);
        _Node().reportAcceptTaskTimeout(tid);
        emit MonitorReport(monitorAddress, tid, ReportAcceptTimeout);
    }

    function reportTaskTimeout(address monitorAddress, uint256 tid) public {
        // TODO: Node should verify the taskTimeout Report by this monitor
        mustAddress(CONTRACT_CHAIN_STORAGE);
        _Storage().addReport(monitorAddress, tid, ReportTimeout, now);
        _Node().reportTaskTimeout(tid);
        emit MonitorReport(monitorAddress, tid, ReportTimeout);
    }

    function _saveCurrentTid(address monitorAddress, uint256 tid) private {
        uint256 currentTid = _Storage().getCurrentTid(monitorAddress);
        if(tid > currentTid) {
            _Storage().setCurrentTid(monitorAddress, tid);
        }
    }
}
