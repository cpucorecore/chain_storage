pragma solidity ^0.5.17;

interface ISetting {
    function replica() external view returns (uint256);
    function setReplica(uint256 replicas) external;
    function initSpace() external view returns (uint256);
    function setInitSpace(uint256 space) external;
    function admin() external view returns (address);
    function setAdmin(address addr) external;
    function maxUserExtLength() external view returns (uint256);
    function setMaxUserExtLength(uint256 length) external;
    function maxNodeExtLength() external view returns (uint256);
    function setMaxNodeExtLength(uint256 length) external;
    function maxMonitorExtLength() external view returns (uint256);
    function setMaxMonitorExtLength(uint256 length) external;
    function maxCidLength() external view returns (uint256);
    function setMaxCidLength(uint256 length) external;
    function maxPidLength() external view returns (uint256);
    function setMaxPidLength(uint256 length) external;

    function maxTimeout() external view returns (uint256);
    function setMaxTimeout(uint256 value) external;

    event SettingChanged(bytes32 indexed name, bytes32 indexed field, uint256 previousValue, uint256 newValue);
}
