pragma solidity ^0.5.2;

import "./base/Importable.sol";
import "./base/ExternalStorable.sol";
import "./lib/SafeMath.sol";
import "./interfaces/storages/IUserStorage.sol";
import "./interfaces/IFile.sol";
import "./interfaces/IUserCallback.sol";

contract UserCallback is Importable, ExternalStorable, IUserCallback {
    using SafeMath for uint256;

    event FileAdded(address indexed owner, string cid); // for User Client
    event FileAddFailed(address indexed owner, string cid); // for User Client
    event FileDeleted(address indexed owner, string cid); // for User Client

    constructor(IResolver _resolver) public Importable(_resolver) {
        setContractName(CONTRACT_USER_CALLBACK);
        imports = [
            CONTRACT_FILE
        ];
    }

    function Storage() private view returns (IUserStorage) {
        return IUserStorage(getStorage());
    }

    function File() private view returns (IFile) {
        return IFile(requireAddress(CONTRACT_FILE));
    }

    function callbackFinishAddFile(address owner, string calldata cid, uint256 size) external {
        mustAddress(CONTRACT_FILE);
        Storage().useStorage(owner, size);
    }

    function callbackFailAddFile(address owner, string calldata cid) external {
        mustAddress(CONTRACT_NODE);
        if(!File().ownerExist(cid, owner)) {
            uint256 invalidAddFileCount = Storage().getInvalidAddFileCount(owner);
            Storage().setInvalidAddFileCount(owner, invalidAddFileCount.add(1));
            emit FileAddFailed(owner, cid);
        }
    }

    function callbackFinishDeleteFile(address owner, string calldata cid, uint256 size) external {
        mustAddress(CONTRACT_FILE);
        emit FileDeleted(owner, cid);
        Storage().deleteFile(owner, cid);
        Storage().freeStorage(owner, size);
    }
}
