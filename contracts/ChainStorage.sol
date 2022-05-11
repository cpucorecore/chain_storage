pragma solidity ^0.5.2;

import "./base/Importable.sol";
import "./base/Pausable.sol";
import "./base/Proxyable.sol";
import "./interfaces/IUser.sol";
import "./interfaces/INode.sol";
import "./interfaces/IMonitor.sol";
import "./interfaces/ISetting.sol";
import "./interfaces/ITask.sol";

contract ChainStorage is Proxyable, Pausable, Importable {
    constructor() public Importable(IResolver(0)) {}

    function initialize(IResolver _resolver) external onlyOwner {
        setInitialized();

        resolver = _resolver;
        setContractName(CONTRACT_CHAIN_STORAGE);

        imports = [
            CONTRACT_USER,
            CONTRACT_NODE,
            CONTRACT_TASK,
            CONTRACT_MONITOR
        ];
    }

    function Setting() private view returns (ISetting) {
        return ISetting(requireAddress(CONTRACT_SETTING));
    }

    function User() private view returns (IUser) {
        return IUser(requireAddress(CONTRACT_USER));
    }

    function Node() private view returns (INode) {
        return INode(requireAddress(CONTRACT_NODE));
    }

    function Monitor() private view returns (IMonitor) {
        return IMonitor(requireAddress(CONTRACT_MONITOR));
    }

    function Task() private view returns (ITask) {
        return ITask(requireAddress(CONTRACT_TASK));
    }

    function userRegister(string calldata ext) external onlyInitialized notPaused {
        User().register(msg.sender, ext);
    }

    function userAddFile(string calldata cid, uint256 size, uint256 duration, string calldata ext) external onlyInitialized notPaused {
        User().addFile(msg.sender, cid, size, duration, ext);
    }

    function userDeleteFile(string calldata cid) external onlyInitialized notPaused {
        User().deleteFile(msg.sender, cid);
    }

    function userSetExt(string calldata ext) external onlyInitialized notPaused {
        User().setExt(msg.sender, ext);
    }

    function userSetFileExt(string calldata cid, string calldata ext) external {
        User().setFileExt(msg.sender, cid, ext);
    }

    function userSetFileDuration(string calldata cid, uint256 duration) external {
        User().setFileDuration(msg.sender, cid, duration);
    }

    function changeUserSpace(address addr, uint256 space) external onlyInitialized notPaused onlyAddress(ACCOUNT_ADMIN) {
        User().changeSpace(addr, space);
    }

    function nodeRegister(uint256 space, string calldata ext) external onlyInitialized notPaused {
        Node().register(msg.sender, space, ext);
    }

    function nodeSetExt(string calldata ext) external {
        Node().setExt(msg.sender, ext);
    }

    function nodeOnline() external onlyInitialized notPaused {
        Node().online(msg.sender);
    }

    function nodeMaintain() external onlyInitialized notPaused {
        Node().maintain(msg.sender);
    }

    function nodeAcceptTask(uint256 tid) external onlyInitialized notPaused {
        Task().acceptTask(msg.sender, tid);
    }

    function nodeFinishTask(uint256 tid) external onlyInitialized notPaused {
        Node().finishTask(msg.sender, tid);
    }

    function nodeFailTask(uint256 tid) external onlyInitialized notPaused {
        Node().failTask(msg.sender, tid);
    }

    function changeNodeSpace(uint256 space) external onlyInitialized notPaused {
        Node().changeSpace(msg.sender, space);
    }

    function monitorRegister(string calldata ext) external onlyInitialized notPaused {
        require(bytes(ext).length <= Setting().getMaxMonitorExtLength(), contractName.concat(": ext too long"));
        Monitor().register(msg.sender, ext);
    }

    function monitorOnline() external onlyInitialized notPaused {
        Monitor().online(msg.sender);
    }

    function monitorMaintain() external onlyInitialized notPaused {
        Monitor().maintain(msg.sender);
    }

    function monitorCheckTask(uint256 tid) external onlyInitialized notPaused returns (bool) {
        return Monitor().checkTask(msg.sender, tid);
    }

    function monitorResetCurrentTid(uint256 tid) external onlyInitialized notPaused {
        Monitor().resetCurrentTid(msg.sender, tid);
    }
}
