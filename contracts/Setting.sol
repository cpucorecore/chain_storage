// SPDX-License-Identifier: MIT
pragma solidity ^0.5.17;

import './base/ExternalStorable.sol';
import './interfaces/ISetting.sol';
import './interfaces/storages/ISettingStorage.sol';

contract Setting is ExternalStorable, ISetting {
    bytes32 private constant REPLICA = 'Replica';
    bytes32 private constant INIT_SPACE = 'InitSpace';

    constructor() public {
        setContractName(CONTRACT_SETTING);
    }

    function Storage() private view returns (ISettingStorage) {
        return ISettingStorage(getStorage());
    }

    function replica() external view returns (uint256) {
        return Storage().getUint(REPLICA);
    }

    function setReplica(uint256 replica) external onlyOwner {
        Storage().setUint(REPLICA, replica);
    }

    function initSpace() external view returns (uint256) {
        return Storage().getUint(INIT_SPACE);
    }

    function setInitSpace(uint256 space) external onlyOwner {
        Storage().setUint(INIT_SPACE, space);
    }
}
