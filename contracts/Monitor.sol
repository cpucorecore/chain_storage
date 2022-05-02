pragma solidity ^0.5.2;
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
        setContractName(CONTRACT_MONITOR);
        imports = [
            CONTRACT_SETTING,
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

    function checkTask(address addr, uint256 tid) external returns (bool) {
        require(Storage().exist(addr), contractName.concat(": monitor not exist"));
        require(IMonitorStorage.Status.Online == Storage().getStatus(addr), contractName.concat(": wrong status, must online"));

        if(Task().isOver(tid)) return false;

        bool shouldContinueCheck = true;
        require(Task().exist(tid), contractName.concat(": task not exist"));

        address node = Task().getNode(tid);
        ITaskStorage.Status status = Task().getStatus(tid);
        if(ITaskStorage.Status.Created == status) {
            uint256 createTime = Task().getCreateTime(tid);
            uint256 acceptTimeout = Setting().getTaskAcceptTimeoutSeconds();
            if(createTime.add(acceptTimeout) > now) {
                reportTaskAcceptTimeout(node, tid);
                shouldContinueCheck = false;
                saveCurrentTid(addr, tid);
            }
        } else if(ITaskStorage.Status.Accepted == status) {
            uint256 acceptTime = Task().getAcceptTime(tid);
            ITaskStorage.Action action = Task().getAction(tid);

            if(ITaskStorage.Action.Add == action) {
                uint256 addFileTimeout = Setting().getAddFileTaskTimeoutSeconds();
                if(acceptTime.add(addFileTimeout) > now) {
                    reportTaskTimeout(node, tid);
                    shouldContinueCheck = false;
                    saveCurrentTid(addr, tid);
                }

                uint256 addFileProgressTimeout = Setting().getAddFileProgressTimeoutSeconds();
                uint256 progressTime;
                uint256 progressLastSize;
                uint256 progressCurrentSize;
                uint256 dropValue;
                (progressTime, progressLastSize, progressCurrentSize, dropValue, dropValue, dropValue) = Task().getAddFileTaskProgress(tid);
                if(progressTime.add(addFileProgressTimeout) > now) {
                    reportTaskTimeout(node, tid);
                    shouldContinueCheck = false;
                    saveCurrentTid(addr, tid);
                }
                if(progressLastSize == progressCurrentSize) {
                    reportTaskTimeout(node, tid);
                    shouldContinueCheck = false;
                    saveCurrentTid(addr, tid);
                }
            } else { // Action.Delete
                uint256 deleteFileTimeout = Setting().getDeleteFileTaskTimeoutSeconds();
                if(acceptTime.add(deleteFileTimeout) > now) {
                    reportTaskTimeout(node, tid);
                    shouldContinueCheck = false;
                    saveCurrentTid(addr, tid);
                }
            }
        }

        return shouldContinueCheck;
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

    function reportTaskAcceptTimeout(address addr, uint256 tid) private {
        Storage().addReport(addr, tid, IMonitorStorage.ReportType.AcceptTimeout, now);
        Node().taskAcceptTimeout(tid);
    }

    function reportTaskTimeout(address addr, uint256 tid) private {
        Storage().addReport(addr, tid, IMonitorStorage.ReportType.Timeout, now);
        Node().taskTimeout(tid);
    }
}
