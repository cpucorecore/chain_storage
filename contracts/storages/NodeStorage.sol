pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import "./ExternalStorage.sol";
import "../interfaces/storages/INodeStorage.sol";
import "../lib/EnumerableSet.sol";

contract FileStorage is ExternalStorage, INodeStorage {
    using EnumerableSet for EnumerableSet.Bytes32Set;

    string[] _pids;
    mapping(string=>uint256) pid2index;
    uint256 nodeCount;

    mapping(string=>NodeInfo) nodes;

    mapping(string=>EnumerableSet.Bytes32Set) node2Cids; // TODO page query
    mapping(bytes32=>string) hash2cids;

    constructor(address _manager) public ExternalStorage(_manager) {}

    function newNode(string memory pid, address chainAccount, uint256 storageSpace) public {
        nodes[pid] = NodeInfo(StatusInfo(Status.Registered, now),
            ServiceInfo(0, 0, 0, now, 0, 0, 0),
            StorageInfo(storageSpace, 0),
            0,
            chainAccount,
            true);

        EnumerableSet.Bytes32Set memory cids;
        node2Cids[pid] = cids;

        _pids.push(pid);
        nodeCount = nodeCount.add(1);
        pid2index[pid] = nodeCount;
    }

    function deleteNode(string memory pid) public {
        require(exist(pid), contractName.concat(": pid not exist pid-", pid));

        delete nodes[pid];
        delete node2Cids[pid];

        uint256 index = pid2index[pid];
        if(0 != index) {
            if(index < nodeCount) {
                _pids[index - 1] = _pids[nodeCount - 1];
            }
            _pids.pop();
            delete pid2index[pid];
            nodeCount = nodeCount.sub(1);
        }
    }

    function exist(string memory pid) public returns(bool) {
        return nodes[pid].exist;
    }

    function pids() public view returns(string[] memory) {
        // TODO page query
        return _pids;
    }

    function cids(string memory pid) public returns(string[] memory) {
        // TODO page query
        EnumerableSet.Bytes32Set storage nodeCids = node2Cids[pid];
        uint count = nodeCids.length();
        string[] memory result = new string[](count);

        for(uint i=0; i<count; i++) {
            result[i] = hash2cids[nodeCids.at(i)];
        }

        return result;
    }

    function updateStorageSpace(string memory pid, uint256 storageSpace) public {
        require(exist(pid), contractName.concat(": node not exist, pid-", pid));
        // require(nodes[pid].storageInfo.storageUsed <= storageSpace, contractName.concat(": storageSpace < storageUsed")); // TODO should move to Node module

        nodes[pid].storageInfo.storageSpace = storageSpace;
    }

    function useStorageSpace(string memory pid, uint256 spaceUsed) public {
        require(exist(pid), contractName.concat(": node not exist, pid-", pid));
        // require(nodes[pid].storageInfo.storageUsed.add(spaceUsed) <= nodes[pid].storageInfo.storageSpace, contractName.concat(": storageSpace not enought")); // TODO should move to Node module

        nodes[pid].storageInfo.storageUsed = nodes[pid].storageInfo.storageUsed.add(spaceUsed);
    }

    function online(string memory pid) public {
        nodes[pid].statusInfo.status = Status.Online;
    }

    function offline(string memory pid) public {
        nodes[pid].statusInfo.status = Status.Offline;
    }

    function maintain(string memory pid) public {
        require(exist(pid), contractName.concat(": node not exist, pid-", pid));
        nodes[pid].statusInfo.status = Status.Maintain;

    }

    function starve(string memory pid, uint256 value) public {
        require(exist(pid), contractName.concat(": node not exist, pid-", pid));
    }

    function starve(string memory pid) public view returns(uint256) {
        return nodes[pid].starve;
    }

    function status(string memory pid) public returns(Status) {

    }

    function storageInfo(string memory pid) public returns(StorageInfo memory) {

    }

    function serviceInfo(string memory pid) public returns(ServiceInfo memory) {

    }

    function maintainCount(string memory pid) public returns(uint256) {

    }

    function offlineCount(string memory pid) public returns(uint256) {

    }

    function chainAccount(string memory pid) public view returns(address) {
        return nodes[pid].chainAccount;
    }
}