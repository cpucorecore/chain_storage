// SPDX-License-Identifier: MIT
pragma solidity ^0.5.17;

import './base/ExternalStorable.sol';
import './interfaces/ISetting.sol';
import './interfaces/storages/ISettingStorage.sol';

contract Setting is ExternalStorable, ISetting {
    bytes32 private constant REPLICA = 'Replica';
    bytes32 private constant INIT_SPACE = 'InitSpace';
    bytes32 private constant ADMIN_ACCOUNT = 'AdminAccount';
    bytes32 private constant MAX_USER_EXT_LENGTH = 'MaxUserExtLength';
    bytes32 private constant MAX_NODE_EXT_LENGTH = 'MaxNodeExtLength';
    bytes32 private constant MAX_MONITOR_EXT_LENGTH = 'MaxMonitorExtLength';
    bytes32 private constant MAX_CID_LENGTH = 'MaxCidLength';
    bytes32 private constant MAX_PID_LENGTH = 'MaxPidLength';
    bytes32 private constant MAX_TIMEOUT = 'MaxTimeout';

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

    function admin() external view returns (address) {
        return Storage().getAddress(ADMIN_ACCOUNT);
    }

    function setAdmin(address addr) external {
        Storage().setAddress(ADMIN_ACCOUNT, addr);
    }

    function maxUserExtLength() external view returns (uint256) {
        return Storage().getUint(MAX_USER_EXT_LENGTH);
    }

    function setMaxUserExtLength(uint256 length) external {
        Storage().setUint(MAX_USER_EXT_LENGTH, length);
    }

    function maxNodeExtLength() external view returns (uint256) {
        return Storage().getUint(MAX_NODE_EXT_LENGTH);
    }

    function setMaxNodeExtLength(uint256 length) external {
        Storage().setUint(MAX_NODE_EXT_LENGTH, length);
    }

    function maxMonitorExtLength() external view returns (uint256) {
        return Storage().getUint(MAX_MONITOR_EXT_LENGTH);
    }

    function setMaxMonitorExtLength(uint256 length) external {
        Storage().setUint(MAX_MONITOR_EXT_LENGTH, length);
    }

    function maxCidLength() external view returns (uint256) {
        return Storage().getUint(MAX_CID_LENGTH);
    }

    function setMaxCidLength(uint256 length) external {
        Storage().setUint(MAX_CID_LENGTH, length);
    }

    function maxPidLength() external view returns (uint256) {
        return Storage().getUint(MAX_PID_LENGTH);
    }

    function setMaxPidLength(uint256 length) external {
        Storage().setUint(MAX_PID_LENGTH, length);
    }

    function maxTimeout() external view returns (uint256) {
        return Storage().getUint(MAX_TIMEOUT);
    }

    function setMaxTimeout(uint256 value) external {
        Storage().setUint(MAX_TIMEOUT, value);
    }
}
