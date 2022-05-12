pragma solidity ^0.5.2;

import './Ownable.sol';
import '../interfaces/IResolver.sol';

contract Importable is Ownable {
    IResolver public resolver;
    bytes32[] internal imports;

    mapping(bytes32 => address) private _cache;

    constructor(IResolver _resolver) public {
        resolver = _resolver;
    }

    function mustAddress(bytes32 name) public {
        require(msg.sender == _cache[name], contractName.concat(': caller is not the ', name));
    }

    modifier containAddress(bytes32[] memory names) {
        require(names.length < 20, contractName.concat(': cannot have more than 20 items'));

        bool contain = false;
        for (uint256 i = 0; i < names.length; i++) {
            if (msg.sender == _cache[names[i]]) {
                contain = true;
                break;
            }
        }
        require(contain, contractName.concat(': caller is not in contains'));
        _;
    }

    function mustContainAddress(bytes32[] memory names) public {
        require(names.length < 20, contractName.concat(': cannot have more than 20 items'));

        bool contain = false;
        for (uint256 i = 0; i < names.length; i++) {
            if (msg.sender == _cache[names[i]]) {
                contain = true;
                break;
            }
        }
        require(contain, contractName.concat(': caller is not in contains'));
    }

    modifier containAddressOrOwner(bytes32[] memory names) {
        require(names.length < 20, contractName.concat(': cannot have more than 20 items'));

        bool contain = false;
        for (uint256 i = 0; i < names.length; i++) {
            if (msg.sender == _cache[names[i]]) {
                contain = true;
                break;
            }
        }
        if (contain == false) contain = (msg.sender == owner);
        require(contain, contractName.concat(': caller is not in dependencies'));
        _;
    }

    function refreshCache() external onlyOwner {
        for (uint256 i = 0; i < imports.length; i++) {
            bytes32 item = imports[i];
            _cache[item] = resolver.getAddress(item);
        }
    }

    function getImports() external view returns (bytes32[] memory) {
        return imports;
    }

    function addAddress(bytes32 name) external onlyOwner {
        _cache[name] = resolver.getAddress(name);
        imports.push(name);
    }

    function requireAddress(bytes32 name) internal view returns (address) {
        require(_cache[name] != address(0), contractName.concat(': Missing ', name));
        return _cache[name];
    }

    function getAddress(bytes32 name) external view returns (address) {
        return _cache[name];
    }
}
