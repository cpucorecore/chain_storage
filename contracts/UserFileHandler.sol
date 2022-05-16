pragma solidity ^0.5.2;

import "./base/Importable.sol";
import "./base/ExternalStorable.sol";
import "./lib/SafeMath.sol";
import "./interfaces/storages/IUserStorage.sol";
import "./interfaces/ISetting.sol";
import "./interfaces/IFile.sol";
import "./interfaces/IUserCallback.sol";

contract UserFileHandler is Importable, ExternalStorable, IUserCallback {
    using SafeMath for uint256;

    event FileAdded(address indexed owner, string cid); // for User Client
    event FileAddFailed(address indexed owner, string cid); // for User Client
    event FileDeleted(address indexed owner, string cid); // for User Client

    constructor(IResolver _resolver) public Importable(_resolver) {
        setContractName(CONTRACT_USER_CALLBACK);
        imports = [
            CONTRACT_SETTING,
            CONTRACT_FILE
        ];
    }

    function Storage() private view returns (IUserStorage) {
        return IUserStorage(getStorage());
    }

    function Setting() private view returns (ISetting) {
        return ISetting(requireAddress(CONTRACT_SETTING));
    }

    function File() private view returns (IFile) {
        return IFile(requireAddress(CONTRACT_FILE));
    }

    function callbackFinishAddFile(address owner, address node, string calldata cid) external {
        mustAddress(CONTRACT_FILE);
        if(!File().ownerExist(cid, owner)) {
            emit FileAdded(owner, cid);
        }
    }

    function callbackFailAddFile(address owner, string calldata cid) external {
        mustAddress(CONTRACT_NODE);
        if(!File().ownerExist(cid, owner)) {
            uint256 invalidAddFileCount = Storage().getInvalidAddFileCount(owner);
            Storage().setInvalidAddFileCount(owner, invalidAddFileCount.add(1));
            emit FileAddFailed(owner, cid);
        }
    }

    function callbackFinishDeleteFile(address owner, address node, string calldata cid) external {
        mustAddress(CONTRACT_FILE);
        emit FileDeleted(owner, cid);
    }
}
