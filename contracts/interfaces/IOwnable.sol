pragma solidity ^0.5.2;

interface IOwnable {
    function contractName() external view returns (string memory);

    event OwnerChanged(address indexed previousValue, address indexed newValue);
    event ManagerChanged(address indexed previousValue, address indexed newValue);
}
