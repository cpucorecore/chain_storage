pragma solidity ^0.5.2;
pragma experimental ABIEncoderV2;

import "./base/Importable.sol";
import "./base/ExternalStorable.sol";
import "./interfaces/IMonitor.sol";
import "./interfaces/storages/IMonitorStorage.sol";
import "./interfaces/ITask.sol";
import "./interfaces/ISetting.sol";
import "./interfaces/INode.sol";
import "./lib/SafeMath.sol";
import "./interfaces/INodeTaskHandler.sol";

contract Monitor is Importable, ExternalStorable, IMonitor {
    using SafeMath for uint256;

    event MonitorReport(address indexed addr, uint256 tid, uint256 reportType);

    constructor(IResolver _resolver) public Importable(_resolver) {
        setContractName(CONTRACT_MONITOR);
        imports = [
            CONTRACT_TASK,
            CONTRACT_NODE_TASK_HANDLER
        ];
    }

    function _Storage() private view returns (IMonitorStorage) {
        return IMonitorStorage(getStorage());
    }

    function _NodeTaskHandler() private view returns (INodeTaskHandler) {
        return INodeTaskHandler(requireAddress(CONTRACT_NODE_TASK_HANDLER));
    }

    function _Task() private view returns (ITask) {
        return ITask(requireAddress(CONTRACT_TASK));
    }

    function register(address addr, string calldata ext) external {
        mustAddress(CONTRACT_MONITOR);
        require(false == _Storage().exist(addr), contractName.concat(": monitor exist"));
        require(bytes(ext).length <= 1024, contractName.concat(": ext too long, must<=1024"));
        _Storage().newMonitor(addr, ext);
    }

    function deRegister(address addr) external {
        mustAddress(CONTRACT_MONITOR);
        require(_Storage().exist(addr), contractName.concat(": monitor not exist"));
        require(MonitorMaintain == _Storage().getStatus(addr), contractName.concat(": must maintain first"));
        _Storage().deleteMonitor(addr);
    }

    function exist(address addr) external view returns (bool) {
        return _Storage().exist(addr);
    }

    function online(address addr) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        require(_Storage().exist(addr), contractName.concat(": monitor not exist"));
        uint256 status = _Storage().getStatus(addr);
        require(MonitorRegistered == status ||
                MonitorMaintain == status, contractName.concat(": wrong status"));

        _Storage().setStatus(addr, MonitorOnline);
        _Storage().addOnlineMonitor(addr);

        if(MonitorRegistered == status) {
            uint256 currentTid = _Task().getCurrentTid();
            _Storage().setFirstOnlineTid(addr, currentTid);
        }
    }

    function maintain(address addr) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        require(_Storage().exist(addr), contractName.concat(": monitor not exist"));
        uint256 status = _Storage().getStatus(addr);
        require(MonitorOnline == status, contractName.concat(": wrong status"));
        _Storage().setStatus(addr, MonitorMaintain);
        _Storage().deleteOnlineMonitor(addr);
    }

    function loadCurrentTid(address addr) external view returns (uint256) {
        return _Storage().getCurrentTid(addr);
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
        mustAddress(CONTRACT_CHAIN_STORAGE);
        _Storage().addReport(addr, tid, ReportAcceptTimeout, now);
        _NodeTaskHandler().reportAcceptTaskTimeout(addr, tid);
        emit MonitorReport(addr, tid, ReportAcceptTimeout);
    }

    function reportTaskTimeout(address addr, uint256 tid) public {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        _Storage().addReport(addr, tid, ReportTimeout, now);
        _NodeTaskHandler().reportTaskTimeout(addr, tid);
        emit MonitorReport(addr, tid, ReportTimeout);
    }

    function _saveCurrentTid(address addr, uint256 tid) private {
        uint256 currentTid = _Storage().getCurrentTid(addr);
        if(tid > currentTid) {
            _Storage().setCurrentTid(addr, tid);
        }
    }
}
