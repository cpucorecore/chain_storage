pragma solidity ^0.5.2;

import "./base/Proxyable.sol";
import "./base/Pausable.sol";
import "./base/Importable.sol";
import "./interfaces/IUser.sol";
import "./interfaces/IUserFileHandler.sol";
import "./interfaces/INode.sol";
import "./interfaces/INodeFileHandler.sol";
import "./interfaces/IMonitor.sol";
import "./interfaces/ITask.sol";

contract ChainStorage is Proxyable, Pausable, Importable {
    constructor() public Importable(IResolver(0)) {}

    function initialize(IResolver _resolver) external onlyOwner {
        setInitialized();

        resolver = _resolver;
        setContractName(CONTRACT_CHAIN_STORAGE);

        imports = [
            CONTRACT_USER,
            CONTRACT_USER_FILE_HANDLER,
            CONTRACT_NODE,
            CONTRACT_TASK,
            CONTRACT_MONITOR
        ];
    }

    function User() private view returns (IUser) {
        return IUser(requireAddress(CONTRACT_USER));
    }

    function UserFileHandler() private view returns (IUserFileHandler) {
        return IUserFileHandler(requireAddress(CONTRACT_USER_FILE_HANDLER));
    }

    function Node() private view returns (INode) {
        return INode(requireAddress(CONTRACT_NODE));
    }

    function NodeFileHandler() private view returns (INodeFileHandler) {
        return INodeFileHandler(requireAddress(CONTRACT_NODE_FILE_HANDLER));
    }

    function Monitor() private view returns (IMonitor) {
        return IMonitor(requireAddress(CONTRACT_MONITOR));
    }

    function Task() private view returns (ITask) {
        return ITask(requireAddress(CONTRACT_TASK));
    }

    function userRegister(string calldata ext) external {
        mustInitialized();
        mustNotPaused();
        User().register(msg.sender, ext);
    }

    function userAddFile(string calldata cid, uint256 size, uint256 duration, string calldata ext) external {
        mustInitialized();
        mustNotPaused();
        UserFileHandler().addFile(msg.sender, cid, size, duration, ext);
    }

    function userDeleteFile(string calldata cid) external {
        mustInitialized();
        mustNotPaused();
        UserFileHandler().deleteFile(msg.sender, cid);
    }

    function userSetExt(string calldata ext) external {
        mustInitialized();
        mustNotPaused();
        User().setExt(msg.sender, ext);
    }

    function userSetFileExt(string calldata cid, string calldata ext) external {
        mustInitialized();
        User().setFileExt(msg.sender, cid, ext);
    }

    function userSetFileDuration(string calldata cid, uint256 duration) external {
        mustInitialized();
        User().setFileDuration(msg.sender, cid, duration);
    }

    function changeUserSpace(address addr, uint256 space) external {
        mustInitialized();
        mustNotPaused();
        mustAddress(ACCOUNT_ADMIN);
        User().changeSpace(addr, space);
    }

    function nodeRegister(uint256 space, string calldata ext) external {
        mustInitialized();
        mustNotPaused();
        Node().register(msg.sender, space, ext);
    }

    function nodeSetExt(string calldata ext) external {
        mustInitialized();
        Node().setExt(msg.sender, ext);
    }

    function nodeOnline() external {
        mustInitialized();
        mustNotPaused();
        Node().online(msg.sender);
    }

    function nodeMaintain() external {
        mustInitialized();
        mustNotPaused();
        Node().maintain(msg.sender);
    }

    function nodeAcceptTask(uint256 tid) external {
        mustInitialized();
        mustNotPaused();
        Task().acceptTask(msg.sender, tid);
    }

    function nodeFinishTask(uint256 tid) external {
        mustInitialized();
        mustNotPaused();
        NodeFileHandler().finishTask(msg.sender, tid);
    }

    function nodeFailTask(uint256 tid) external {
        mustInitialized();
        mustNotPaused();
        NodeFileHandler().failTask(msg.sender, tid);
    }

    function changeNodeSpace(uint256 space) external {
        mustInitialized();
        mustNotPaused();
        Node().changeSpace(msg.sender, space);
    }

    function monitorRegister(string calldata ext) external {
        mustInitialized();
        mustNotPaused();
        Monitor().register(msg.sender, ext);
    }

    function monitorOnline() external {
        mustInitialized();
        mustNotPaused();
        Monitor().online(msg.sender);
    }

    function monitorMaintain() external {
        mustInitialized();
        mustNotPaused();
        Monitor().maintain(msg.sender);
    }

    function monitorResetCurrentTid(uint256 tid) external {
        mustInitialized();
        mustNotPaused();
        Monitor().resetCurrentTid(msg.sender, tid);
    }
}
