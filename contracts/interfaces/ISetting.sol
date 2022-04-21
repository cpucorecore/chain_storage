pragma solidity ^0.5.17;

interface ISetting {
    function getReplica() external view returns (uint256);
    function setReplica(uint256 replicas) external;

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

    function getMaxCidLength() external view returns (uint256);
    function setMaxCidLength(uint256 length) external;

    function getMaxPidLength() external view returns (uint256);
    function setMaxPidLength(uint256 length) external;

    function getMaxTimeout() external view returns (uint256);
    function setMaxTimeout(uint256 value) external;

    event SettingChanged(bytes32 indexed name, bytes32 indexed field, uint256 previousValue, uint256 newValue);
}
