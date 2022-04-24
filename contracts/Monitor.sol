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
    using SafeMath for uint256;

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

    function Task() private view returns (ITask) {
        return ITask(requireAddress(CONTRACT_TASK));
    }

    function register(address addr, string calldata ext) external {
        require(false == Storage().exist(addr), contractName.concat(": monitor exist"));
        require(bytes(ext).length <= 1024, contractName.concat(": ext too long, must<=1024"));
        Storage().newMonitor(addr, ext);
    }

    function deRegister(address addr) external {
        require(Storage().exist(addr), contractName.concat(": monitor not exist"));
        require(IMonitorStorage.Status.Maintain == Storage().getStatus(addr), contractName.concat(": must maintain first"));
        Storage().deleteMonitor(addr);
    }

    function online(address addr) external {
        require(Storage().exist(addr), contractName.concat(": monitor not exist"));
        IMonitorStorage.Status status = Storage().getStatus(addr);
        require(IMonitorStorage.Status.Registered == status ||
                IMonitorStorage.Status.Maintain == status, contractName.concat(": wrong status"));

        Storage().setStatus(addr, IMonitorStorage.Status.Online);
        Storage().addOnlineMonitor(addr);

        if(IMonitorStorage.Status.Registered == status) {
            uint256 currentTid = Task().getCurrentTid();
            Storage().setFirstOnlineTid(addr, currentTid);
        }
    }

    function maintain(address addr) external {
        require(Storage().exist(addr), contractName.concat(": monitor not exist"));
        IMonitorStorage.Status status = Storage().getStatus(addr);
        require(IMonitorStorage.Status.Online == status, contractName.concat(": wrong status"));
        Storage().setStatus(addr, IMonitorStorage.Status.Maintain);
        Storage().deleteOnlineMonitor(addr);
    }

    function checkTask(address addr, uint256 tid) external {
        require(Storage().exist(addr), contractName.concat(": monitor not exist"));
        IMonitorStorage.Status status = Storage().getStatus(addr);
        require(IMonitorStorage.Status.Online == status, contractName.concat(": wrong status, must online"));

        ITaskStorage.TaskItem memory task = Task().getTaskItem(tid);
        require(task.exist, contractName.concat(": task not exist"));
        ITaskStorage.StatusInfo memory taskStatus = Task().getStatusInfo(tid);
        uint256 timeoutAcceptSeconds = Setting().getTaskAcceptTimeoutSeconds();

        if(ITaskStorage.Status.Created == taskStatus.status) {
            if(taskStatus.createTime.add(timeoutAcceptSeconds) > now) {
                reportTaskAcceptTimeout(task.node, tid);
                saveCurrentTid(addr, tid);
            }
        } else if(ITaskStorage.Status.Accepted == taskStatus.status) {
            if(ITaskStorage.Action.Add == task.action) {
                uint256 addFileProgressTimeout = Setting().getAddFileProgressTimeoutSeconds();
                uint256 addFileTaskTimeout = Setting().getAddFileTaskTimeoutSeconds();
                if(taskStatus.acceptTime.add(addFileTaskTimeout) > now) {
                    reportTaskTimeout(task.node, tid);
                    saveCurrentTid(addr, tid);
                } else {
                    ITaskStorage.AddFileTaskProgress memory taskProgress = Task().getAddFileTaskProgress(tid);
                    if(taskProgress.time.add(addFileProgressTimeout) > now) {
                        reportTaskTimeout(task.node, tid);
                        saveCurrentTid(addr, tid);
                    } else if(taskProgress.currentSize == taskProgress.lastSize) {
                        reportTaskTimeout(task.node, tid);
                        saveCurrentTid(addr, tid);
                    }
                }
            } else { // Action.Delete
                uint256 deleteFileTaskTimeout = Setting().getDeleteFileTaskTimeoutSeconds();
                if(taskStatus.acceptTime.add(deleteFileTaskTimeout) > now) {
                    reportTaskTimeout(task.node, tid);
                    saveCurrentTid(addr, tid);
                }
            }
        } else {
        }
    }

    function loadCurrentTid(address addr) external returns (uint256) {
        return Storage().getCurrentTid(addr);
    }

    function saveCurrentTid(address addr, uint256 tid) private {
        uint256 currentTid = Storage().getCurrentTid(addr);
        if(tid > currentTid) {
            Storage().setCurrentTid(addr, tid);
        }
    }

    function resetCurrentTid(address addr, uint256 tid) external {
        uint256 firstOnlineTid = Storage().getFirstOnlineTid(addr);
        if(tid<firstOnlineTid) {
            tid = firstOnlineTid;
        }
        Storage().setCurrentTid(addr, tid);
    }

    //////////////////// private functions ////////////////////
    function reportTaskAcceptTimeout(address addr, uint256 tid) private {
        Storage().addReport(addr, tid, IMonitorStorage.ReportType.AcceptTimeout, now);
        Node().taskAcceptTimeout(tid);
    }

    function reportTaskTimeout(address addr, uint256 tid) private {
        Storage().addReport(addr, tid, IMonitorStorage.ReportType.Timeout, now);
        Node().taskTimeout(tid);
    }
}
