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

    bytes32 private constant TASK_ACCEPT_TIMEOUT_SECONDS = 'TaskAcceptTimeoutSeconds';
    bytes32 private constant ADD_FILE_TASK_TIMEOUT_SECONDS = 'AddFileTaskTimeoutSeconds';
    bytes32 private constant ADD_FILE_PROGRESS_TIMEOUT_SECONDS = 'AddFileProgressTimeoutSeconds';
    bytes32 private constant DELETE_FILE_TASK_TIMEOUT_SECONDS = 'DeleteFileTaskTimeoutSeconds';

    bytes32 private constant MAX_ADD_FILE_RETRY_COUNT = 'MaxAddFileFailedCount';

    constructor() public {
        setContractName(CONTRACT_SETTING);
    }

    function Storage() private view returns (ISettingStorage) {
        return ISettingStorage(getStorage());
    }

    function getReplica() external view returns (uint256) {
        return Storage().getUint(REPLICA);
    }

    function setReplica(uint256 replica) external onlyOwner {
        Storage().setUint(REPLICA, replica);
    }

    function getInitSpace() external view returns (uint256) {
        return Storage().getUint(INIT_SPACE);
    }

    function setInitSpace(uint256 space) external onlyOwner {
        Storage().setUint(INIT_SPACE, space);
    }

    function getAdmin() external view returns (address) {
        return Storage().getAddress(ADMIN_ACCOUNT);
    }

    function setAdmin(address addr) external {
        Storage().setAddress(ADMIN_ACCOUNT, addr);
    }

    function getMaxUserExtLength() external view returns (uint256) {
        return Storage().getUint(MAX_USER_EXT_LENGTH);
    }

    function setMaxUserExtLength(uint256 length) external {
        Storage().setUint(MAX_USER_EXT_LENGTH, length);
    }

    function getMaxNodeExtLength() external view returns (uint256) {
        return Storage().getUint(MAX_NODE_EXT_LENGTH);
    }

    function setMaxNodeExtLength(uint256 length) external {
        Storage().setUint(MAX_NODE_EXT_LENGTH, length);
    }

    function getMaxMonitorExtLength() external view returns (uint256) {
        return Storage().getUint(MAX_MONITOR_EXT_LENGTH);
    }

    function setMaxMonitorExtLength(uint256 length) external {
        Storage().setUint(MAX_MONITOR_EXT_LENGTH, length);
    }

    function getMaxCidLength() external view returns (uint256) {
        return Storage().getUint(MAX_CID_LENGTH);
    }

    function setMaxCidLength(uint256 length) external {
        Storage().setUint(MAX_CID_LENGTH, length);
    }

    function getTaskAcceptTimeoutSeconds() external view returns (uint256) {
        return Storage().getUint(TASK_ACCEPT_TIMEOUT_SECONDS);
    }

    function setTaskAcceptTimeoutSeconds(uint256 value) external {
        Storage().setUint(TASK_ACCEPT_TIMEOUT_SECONDS, value);
    }

    function getAddFileTaskTimeoutSeconds() external view returns (uint256) {
        return Storage().getUint(ADD_FILE_TASK_TIMEOUT_SECONDS);
    }

    function setAddFileTaskTimeoutSeconds(uint256 value) external {
        Storage().setUint(ADD_FILE_TASK_TIMEOUT_SECONDS, value);
    }

    function getDeleteFileTaskTimeoutSeconds() external view returns (uint256) {
        return Storage().getUint(DELETE_FILE_TASK_TIMEOUT_SECONDS);
    }

    function setDeleteFileTaskTimeoutSeconds(uint256 value) external {
        Storage().setUint(DELETE_FILE_TASK_TIMEOUT_SECONDS, value);
    }

    function getAddFileProgressTimeoutSeconds() external view returns (uint256) {
        return Storage().getUint(ADD_FILE_PROGRESS_TIMEOUT_SECONDS);
    }

    function setAddFileProgressTimeoutSeconds(uint256 value) external {
        Storage().setUint(ADD_FILE_PROGRESS_TIMEOUT_SECONDS, value);
    }

    function getMaxAddFileFailedCount() external view returns (uint256) {
        return Storage().getUint(MaxAddFileFailedCount);
    }

    function setMaxAddFileFailedCount(uint256 value) external {
        Storage().setUint(MaxAddFileRetryCount, value);
    }
}
