pragma solidity ^0.5.17;

import "./base/Importable.sol";
import "./base/ExternalStorable.sol";
import "./interfaces/IFile.sol";
import "./interfaces/storages/IFileStorage.sol";

contract File is Importable, ExternalStorable, IFile {
    constructor(IResolver _resolver) public Importable(_resolver) {
        setContractName(CONTRACT_FILE);
        imports = [
            CONTRACT_USER,
            CONTRACT_NODE,
            CONTRACT_TASK
        ];
    }

    function Storage() private view returns(IFileStorage) {
        return IFileStorage(getStorage());
    }

}
