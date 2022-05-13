pragma solidity ^0.5.2;
pragma experimental ABIEncoderV2;

import "./base/Importable.sol";
import "./base/ExternalStorable.sol";
import "./interfaces/IMonitor.sol";
import "./interfaces/storages/IMonitorStorage.sol";
import "./interfaces/ITask.sol";
import "./interfaces/ISetting.sol";
import "./interfaces/INode.sol";
import "./interfaces/IHistory.sol";
import "./lib/SafeMath.sol";
import "./interfaces/INodeFileHandler.sol";
import "./interfaces/storages/ITaskStorage.sol";

contract Monitor is Importable, ExternalStorable, IMonitor {
    using SafeMath for uint256;

    constructor(IResolver _resolver) public Importable(_resolver) {
        setContractName(CONTRACT_MONITOR);
        imports = [
            CONTRACT_SETTING,
            CONTRACT_USER,
            CONTRACT_TASK,
            CONTRACT_TASK_STORAGE,
            CONTRACT_HISTORY
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

    function NodeFileHandler() private view returns (INodeFileHandler) {
        return INodeFileHandler(requireAddress(CONTRACT_NODE_FILE_HANDLER));
    }

    function Task() private view returns (ITask) {
        return ITask(requireAddress(CONTRACT_TASK));
    }

    function TaskStorage() private view returns (ITaskStorage) {
        return ITaskStorage(requireAddress(CONTRACT_TASK_STORAGE));
    }

    function History() private view returns (IHistory) {
        return IHistory(requireAddress(CONTRACT_HISTORY));
    }

    function register(address addr, string calldata ext) external {
        mustAddress(CONTRACT_MONITOR);
        require(false == Storage().exist(addr), contractName.concat(": monitor exist"));
        require(bytes(ext).length <= 1024, contractName.concat(": ext too long, must<=1024"));
        Storage().newMonitor(addr, ext);
    }

    function deRegister(address addr) external {
        mustAddress(CONTRACT_MONITOR);
        require(Storage().exist(addr), contractName.concat(": monitor not exist"));
        require(MonitorMaintain == Storage().getStatus(addr), contractName.concat(": must maintain first"));
        Storage().deleteMonitor(addr);
    }

    function exist(address addr) external view returns (bool) {
        return Storage().exist(addr);
    }

    function online(address addr) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        require(Storage().exist(addr), contractName.concat(": monitor not exist"));
        uint256 status = Storage().getStatus(addr);
        require(MonitorRegistered == status ||
                MonitorMaintain == status, contractName.concat(": wrong status"));

        Storage().setStatus(addr, MonitorOnline);
        Storage().addOnlineMonitor(addr);

        if(MonitorRegistered == status) {
            uint256 currentTid = TaskStorage().getCurrentTid();
            Storage().setFirstOnlineTid(addr, currentTid);
        }
    }

    function maintain(address addr) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        require(Storage().exist(addr), contractName.concat(": monitor not exist"));
        uint256 status = Storage().getStatus(addr);
        require(MonitorOnline == status, contractName.concat(": wrong status"));
        Storage().setStatus(addr, MonitorMaintain);
        Storage().deleteOnlineMonitor(addr);
    }

    // TODO implement out of contract, to build a service of monitor
//    function checkTask(address addr, uint256 tid) external onlyAddress(CONTRACT_CHAIN_STORAGE) returns (bool) {
//        require(Storage().exist(addr), contractName.concat(": monitor not exist"));
//        require(MonitorOnline == Storage().getStatus(addr), contractName.concat(": wrong status, must online"));
//
//        if(Task().isOver(tid)) return false;
//
//        bool shouldContinueCheck = true;
//        require(Task().exist(tid), contractName.concat(": task not exist"));
//
//        address node = Task().getNode(tid);
//        uint8 status = Task().getStatus(tid);
//        if(TaskCreated == status) {
//            uint256 createTime = Task().getCreateTime(tid);
//            uint256 acceptTimeout = Setting().getTaskAcceptTimeout();
//            if(createTime.add(acceptTimeout) > now) {
//                reportTaskAcceptTimeout(node, tid);
//                shouldContinueCheck = false;
//                saveCurrentTid(addr, tid);
//            }
//        } else if(TaskAccepted == status) {
//            uint256 acceptTime = Task().getAcceptTime(tid);
//            uint8 action = Task().getAction(tid);
//
//            if(Add == action) {
//                uint256 addFileTimeout = Setting().getAddFileTaskTimeout();
//                if(acceptTime.add(addFileTimeout) > now) {
//                    reportTaskTimeout(node, tid);
//                    shouldContinueCheck = false;
//                    saveCurrentTid(addr, tid);
//                }
//
//                uint256 addFileProgressTimeout = Setting().getAddFileProgressTimeout();
//                uint256 progressTime;
//                uint256 progressLastSize;
//                uint256 progressCurrentSize;
//                uint256 dropValue;
//                (progressTime, progressLastSize, progressCurrentSize, dropValue, dropValue, dropValue) = Task().getAddFileTaskProgress(tid);
//                if(progressTime.add(addFileProgressTimeout) > now) {
//                    reportTaskTimeout(node, tid);
//                    shouldContinueCheck = false;
//                    saveCurrentTid(addr, tid);
//                }
//                if(progressLastSize == progressCurrentSize) {
//                    reportTaskTimeout(node, tid);
//                    shouldContinueCheck = false;
//                    saveCurrentTid(addr, tid);
//                }
//            } else { // Action.Delete
//                uint256 deleteFileTimeout = Setting().getDeleteFileTaskTimeout();
//                if(acceptTime.add(deleteFileTimeout) > now) {
//                    reportTaskTimeout(node, tid);
//                    shouldContinueCheck = false;
//                    saveCurrentTid(addr, tid);
//                }
//            }
//        }
//
//        return shouldContinueCheck;
//    }

    function loadCurrentTid(address addr) external view returns (uint256) {
        return Storage().getCurrentTid(addr);
    }

    function resetCurrentTid(address addr, uint256 tid) external {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        uint256 firstOnlineTid = Storage().getFirstOnlineTid(addr);
        if(tid<firstOnlineTid) {
            Storage().setCurrentTid(addr, firstOnlineTid);
        } else {
            Storage().setCurrentTid(addr, tid);
        }
    }

    function reportTaskAcceptTimeout(address addr, uint256 tid) public {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        Storage().addReport(addr, tid, ReportAcceptTimeout, now);
        string memory cid = TaskStorage().getCid(tid);
        History().addMonitorAction(addr, tid, ReportAcceptTimeout, keccak256(bytes(cid)));
        NodeFileHandler().taskAcceptTimeout(addr, tid);
    }

    function reportTaskTimeout(address addr, uint256 tid) public {
        mustAddress(CONTRACT_CHAIN_STORAGE);
        Storage().addReport(addr, tid, ReportTimeout, now);
        string memory cid = TaskStorage().getCid(tid);
        History().addMonitorAction(addr, tid, ReportTimeout, keccak256(bytes(cid)));
        NodeFileHandler().taskTimeout(addr, tid);
    }

    function saveCurrentTid(address addr, uint256 tid) private {
        uint256 currentTid = Storage().getCurrentTid(addr);
        if(tid > currentTid) {
            Storage().setCurrentTid(addr, tid);
        }
    }
}
