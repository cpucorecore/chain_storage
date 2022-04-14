pragma solidity ^0.5.17;

interface ISetting {
    function getReplicas() external view returns (uint256);
    function getInitSpace() external view returns (uint256);

    event SettingChanged(bytes32 indexed name, bytes32 indexed field, uint256 previousValue, uint256 newValue);
}
