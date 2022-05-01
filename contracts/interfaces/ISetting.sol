pragma solidity ^0.5.2;

interface ISetting {
    function getReplica() external view returns (uint256);
    function setReplica(uint256 replica) external;

    function getInitSpace() external view returns (uint256);
    function setInitSpace(uint256 space) external;

    function getAdmin() external view returns (address);
    function setAdmin(address addr) external;

    function getMaxUserExtLength() external view returns (uint256);
    function setMaxUserExtLength(uint256 length) external;

    function getMaxNodeExtLength() external view returns (uint256);
    function setMaxNodeExtLength(uint256 length) external;

    function getMaxMonitorExtLength() external view returns (uint256);
    function setMaxMonitorExtLength(uint256 length) external;

    function getMaxFileExtLength() external view returns (uint256);
    function setMaxFileExtLength(uint256 length) external;

    function getMaxCidLength() external view returns (uint256);
    function setMaxCidLength(uint256 length) external;

    function getTaskAcceptTimeoutSeconds() external view returns (uint256);
    function setTaskAcceptTimeoutSeconds(uint256 value) external;

    function getAddFileTaskTimeoutSeconds() external view returns (uint256);
    function setAddFileTaskTimeoutSeconds(uint256 value) external;

    function getDeleteFileTaskTimeoutSeconds() external view returns (uint256);
    function setDeleteFileTaskTimeoutSeconds(uint256 value) external;

    function getAddFileProgressTimeoutSeconds() external view returns (uint256);
    function setAddFileProgressTimeoutSeconds(uint256 value) external;

    function getMaxAddFileFailedCount() external view returns (uint256);
    function setMaxAddFileFailedCount(uint256 value) external;

    event SettingChanged(bytes32 indexed name, bytes32 indexed field, uint256 previousValue, uint256 newValue);
}
