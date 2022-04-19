pragma solidity ^0.5.17;

import "./base/Importable.sol";
import "./base/Pausable.sol";
import "./base/Proxyable.sol";
import "./interfaces/IChainStorage.sol";
import "./interfaces/IUser.sol";
import "./interfaces/INode.sol";
import "./interfaces/IMonitor.sol";
import "./interfaces/ISetting.sol";

contract ChainStorage is Proxyable, Pausable, Importable, IChainStorage {
    constructor() public Importable(IResolver(0)) {}

    function initialize(IResolver _resolver) external onlyOwner {
        setInitialized();

        resolver = _resolver;
        setContractName(CONTRACT_CHAIN_STORAGE);

        imports = [
        CONTRACT_SETTING,
        CONTRACT_USER,
        CONTRACT_FILE,
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

    function userRegister(string calldata ext) external onlyInitialized notPaused {
        User().register(msg.sender, ext);
    }

    function userAddFile(string calldata cid, uint256 size, uint256 duration, string calldata ext) external onlyInitialized notPaused {
        require(size > 0, contractName.concat(": size must > 0"));
        require(bytes(ext).length <= Setting().maxUserExtLength(), contractName.concat(": ext too long"));
        require(bytes(cid).length <= Setting().maxCidLength(), contractName.concat(": cid too long"));

        User().addFile(msg.sender, cid, size, duration, ext);
    }

    function userDeleteFile(string calldata cid) external onlyInitialized notPaused {
        User().deleteFile(msg.sender, cid);
    }

    function nodeRegister(string calldata pid, uint256 space, string calldata ext) external onlyInitialized notPaused {
        require(bytes(pid).length <= Setting().maxPidLength(), contractName.concat(": pid too long"));
        require(bytes(ext).length <= Setting().maxNodeExtLength(), contractName.concat(": ext too long"));
        require(space > 0, contractName.concat(": space must > 0"));

        Node().register(msg.sender, pid, space, ext);
    }

    function nodeOnline() external onlyInitialized notPaused {
        Node().online(msg.sender);
    }

    function monitorRegister(string calldata ext) external {
        require(bytes(ext).length <= Setting().maxMonitorExtLength(), contractName.concat(": ext too long"));
        Monitor().register(msg.sender, ext);
    }

    function monitorOnline() external {
        Monitor().online(msg.sender);
    }
}
