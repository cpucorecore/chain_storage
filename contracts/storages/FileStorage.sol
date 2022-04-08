pragma solidity ^0.5.17;

import './ExternalStorage.sol';
import '../interfaces/storages/IFileStorage.sol';

contract FileStorage is ExternalStorage, IFileStorage {
    // TODO reconstruction
    mapping(string => uint256) public sizes;
    mapping(string => uint256) public createdTimes;
    mapping(string => mapping(address => bool)) public owners;
    mapping(string => mapping(string => bool)) public nodes;

    constructor(address _manager) public ExternalStorage(_manager) {}

    function newFile(string memory cid, uint256 size, address owner, uint256 createdTime) public returns(bool) {
        if(0 != sizes[cid]) {
            return false;
        }

        sizes[cid] = size;
        createdTimes[cid] = createdTime;
        owners[cid][owner] = true;

        return true;
    }

    function exist(string memory cid) public view returns(bool) {
        return (0 != sizes[cid]);
    }

    function size(string memory cid) public view returns(uint256) {
        return sizes[cid];
    }

    function createdTime(string memory cid) public view returns(uint256) {
        return createdTimes[cid];
    }

    function ownerExist(string memory cid, address owner) public view returns(bool) {
        return owners[cid][owner];
    }

    function addOwner(string memory cid, address owner) public {
        owners[cid][owner] = true;
    }

    function delOwner(string memory cid, address owner) public {
        delete owners[cid][owner];
    }

    function nodeExist(string memory cid, string memory pid) public view returns(bool) {
        return nodes[cid][pid];
    }

    function addNode(string memory cid, string memory pid) public {
        nodes[cid][pid] = true;
    }

    function delNode(string memory cid, string memory pid) public {
        delete nodes[cid][pid];
    }
}
