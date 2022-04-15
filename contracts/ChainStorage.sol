pragma solidity ^0.5.17;

import "./base/Importable.sol";
import "./base/Pausable.sol";
import "./base/Proxyable.sol";
import "./interfaces/IChainStorage.sol";
import "./interfaces/IUser.sol";
import "./interfaces/INode.sol";

contract ChainStorage is Proxyable, Pausable, Importable, IChainStorage {
    constructor() public Importable(IResolver(0)) {}

    function initialize(IResolver _resolver) external onlyOwner returns (bool) {
        setInitialized();

        resolver = _resolver;
        setContractName(CONTRACT_CHAIN_STORAGE);

        imports = [
        CONTRACT_SETTING,
        CONTRACT_USER,
        CONTRACT_FILE,
        CONTRACT_NODE,
        CONTRACT_TASK
        ];

        return true;
    }

    function User() private view returns (IUser) {
        return IUser(requireAddress(CONTRACT_USER));
    }

    function Node() private view returns (INode) {
        return INode(requireAddress(CONTRACT_USER));
    }

    function userRegister(uint256 space) external onlyInitialized notPaused returns (bool) {
        User().register(msg.sender, space);
        return true;
    }

    function userAddFile(string calldata cid, uint256 size, uint256 duration, string calldata ext) external onlyInitialized notPaused returns (bool) {
        User().addFile(msg.sender, cid, size, duration, ext);
        return true;
    }

    function userDeleteFile(string calldata cid) external onlyInitialized notPaused returns (bool) {
        User().deleteFile(msg.sender, cid);
        return true;
    }

    function nodeRegister(string calldata pid, uint256 space) external onlyInitialized notPaused returns (bool) {
        Node().register(msg.sender, pid, space);
        return true;
    }

    function nodeOnline() external onlyInitialized notPaused returns (bool) {
        Node().online(msg.sender);
        return true;
    }
}
