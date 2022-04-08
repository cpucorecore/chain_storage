pragma solidity ^0.5.17;

interface IResolver {
    function getAddress(bytes32 name) external view returns (address);

    event AddressChanged(bytes32 indexed name, address indexed previousValue, address indexed newValue);
}
