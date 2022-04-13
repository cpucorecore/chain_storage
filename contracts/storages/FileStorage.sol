pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import './ExternalStorage.sol';
import '../interfaces/storages/IFileStorage.sol';

contract FileStorage is ExternalStorage, IFileStorage {
    mapping(string => FileItem) files;
    mapping(bytes32 => string) hash2pids;

    constructor(address _manager) public ExternalStorage(_manager) {}

    function newFile(string memory cid, uint256 size, address owner, uint256 createdTime) public returns(bool) {
        if(exist(cid)) {
            return false;
        }

        EnumerableSet.AddressSet memory owners;
        EnumerableSet.Bytes32Set memory nodes;

        files[cid] = FileItem(true, size, createdTime, owners, nodes);

        addOwner(cid, owner);

        return true;
    }

    function deleteFile(string memory cid) public {
        require(files[cid].exist, contractName.concat(": cid not exist cid-", cid));

        FileItem storage file = files[cid];
        require(0 != file.owners.length(), contractName.concat(": owners not empty cid-", cid));

        delete files[cid];
    }

    function exist(string memory cid) public view returns(bool) {
        return files[cid].exist;
    }

    function size(string memory cid) public view returns(uint256) {
        return files[cid].size;
    }

    function createdTime(string memory cid) public view returns(uint256) {
        return files[cid].createdTime;
    }

    function ownerExist(string memory cid, address owner) public view returns(bool) {
        return files[cid].owners.contains(owner);
    }

    function addOwner(string memory cid, address owner) public {
        EnumerableSet.AddressSet storage owners = files[cid].owners;
        owners.add(owner);
    }

    function delOwner(string memory cid, address owner) public {
        EnumerableSet.AddressSet storage owners = files[cid].owners;
        owners.remove(owner);
    }

    function owners(string memory cid) public returns(address[] memory) {
        EnumerableSet.AddressSet storage fileOwners = files[cid].owners;
        uint count = fileOwners.length();
        address[] memory result = new address[](count);

        for(uint i=0; i<count; i++) {
            result[i] = fileOwners.at(i);
        }

        return result;
    }

    function nodeExist(string memory cid, string memory pid) public view returns(bool) {
        return files[cid].nodes.contains(keccak256(bytes(pid)));
    }

    function addNode(string memory cid, string memory pid) public {
        EnumerableSet.Bytes32Set storage nodes = files[cid].nodes;
        bytes32 hash = keccak256(bytes(pid));
        nodes.add(hash);

        hash2pids[hash] = pid;
    }

    function delNode(string memory cid, string memory pid) public {
        EnumerableSet.Bytes32Set storage nodes = files[cid].nodes;
        bytes32 hash = keccak256(bytes(pid));
        nodes.remove(hash);
    }

    function nodes(string memory cid) public returns(string[] memory) {
        EnumerableSet.Bytes32Set storage fileNodes = files[cid].nodes;
        uint256 count = fileNodes.length();
        string[] memory result = new string[](count);
        bytes32 hash;

        for(uint256 i=0; i<count; i++) {
            hash = fileNodes.at(i);
            result[i] = hash2pids[hash];
        }

        return result;
    }
}
