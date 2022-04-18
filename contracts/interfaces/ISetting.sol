pragma solidity ^0.5.17;

interface ISetting {
    function replica() external view returns (uint256);
    function setReplica(uint256 replicas) external;
    function initSpace() external view returns (uint256);
    function setInitSpace(uint256 space) external;

    event SettingChanged(bytes32 indexed name, bytes32 indexed field, uint256 previousValue, uint256 newValue);
}
