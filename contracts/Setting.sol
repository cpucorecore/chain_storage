// SPDX-License-Identifier: MIT
pragma solidity ^0.5.17;

import './base/ExternalStorable.sol';
import './interfaces/ISetting.sol';
import './interfaces/storages/ISettingStorage.sol';

contract Setting is ExternalStorable, ISetting {
    bytes32 private constant REPLICAS = 'Replicas';
    bytes32 private constant INIT_SPACE = 'InitSpace';

    constructor() public {
        setContractName(CONTRACT_SETTING);
    }

    function Storage() private view returns (ISettingStorage) {
        return ISettingStorage(getStorage());
    }

    function setReplicas(uint256 replicas) external onlyOwner {
        Storage().setUint(REPLICAS, replicas);
    }

    function getReplicas() external view returns (uint256) {
        return Storage().getUint(REPLICAS);
    }

    function setInitSpace(uint256 initSpace) external onlyOwner {
        Storage().setUint(INIT_SPACE, initSpace);
    }

    function getInitSpace() external view returns (uint256) {
        return Storage().getUint(INIT_SPACE);
    }
}
