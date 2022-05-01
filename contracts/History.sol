// SPDX-License-Identifier: MIT
pragma solidity ^0.5.2;
pragma experimental ABIEncoderV2;

import './lib/SafeMath.sol';
import './lib/Paging.sol';
import './base/Importable.sol';
import './interfaces/IHistory.sol';

contract History is Importable, IHistory {
    using SafeMath for uint256;

    UserAction[] private userActions;
    mapping(address=>uint256[]) private user2userActionIndexes;
    mapping(bytes32=>uint256[]) private cidHash2userActionIndexes;
    mapping(address=>mapping(bytes32=>uint256[])) user2cidHash2userActionIndexes;

    NodeAction[] private nodeActions;
    mapping(address=>uint256[]) private node2nodeActionIndexes;
    mapping(bytes32=>uint256[]) private cidHash2nodeActionIndexes;
    mapping(address=>mapping(bytes32=>uint256[])) node2cidHash2nodeActionIndexes;

    MonitorAction[] private monitorActions;
    mapping(address=>uint256[]) private monitor2monitorActionIndexes;
    mapping(bytes32=>uint256[]) private cidHash2monitorActionIndexes;
    mapping(address=>mapping(bytes32=>uint256[])) monitor2cidHash2monitorActionIndexes;

    constructor(IResolver _resolver) public Importable(_resolver) {
        setContractName(CONTRACT_HISTORY);
        imports = [
            CONTRACT_SETTING
        ];
    }

    function addUserAction(address addr, ActionType actionType, bytes32 cidHash) external {
        uint256 index = userActions.push(UserAction(now, addr, actionType, cidHash));
        user2userActionIndexes[addr].push(index);
        cidHash2userActionIndexes[cidHash].push(index);
        user2cidHash2userActionIndexes[addr][cidHash].push(index);
    }

    function getUserHistoryNumber() external view returns (uint256) {
        return userActions.length;
    }

    function getUserHistory(uint256 index) external view returns (UserAction memory) {
        assert(index <= userActions.length);
        return userActions[index];
    }

    function getUserHistoryIndexesByUser(address addr, uint256 pageSize, uint256 pageNumber) external view returns (uint256[] memory, Paging.Page memory) {
        Paging.Page memory page = Paging.getPage(user2userActionIndexes[addr].length, pageSize, pageNumber);
        uint256 start = page.pageNumber.sub(1).mul(page.pageSize);
        uint256[] memory result = new uint256[](page.pageRecords);
        for(uint256 i=0; i<page.pageRecords; i++) {
            result[i] = user2userActionIndexes[addr][start+i];
        }
        return (result, page);
    }

    function getUserHistoryIndexesByCidHash(bytes32 cidHash, uint256 pageSize, uint256 pageNumber) external view returns (uint256[] memory, Paging.Page memory) {
        Paging.Page memory page = Paging.getPage(cidHash2userActionIndexes[cidHash].length, pageSize, pageNumber);
        uint256 start = page.pageNumber.sub(1).mul(page.pageSize);
        uint256[] memory result = new uint256[](page.pageRecords);
        for(uint256 i=0; i<page.pageRecords; i++) {
            result[i] = cidHash2userActionIndexes[cidHash][start+i];
        }
        return (result, page);
    }

    function getUserHistoryIndexesByUserAndCidHash(address addr, bytes32 cidHash, uint256 pageSize, uint256 pageNumber) external view returns (uint256[] memory, Paging.Page memory) {
        Paging.Page memory page = Paging.getPage(user2cidHash2userActionIndexes[addr][cidHash].length, pageSize, pageNumber);
        uint256 start = page.pageNumber.sub(1).mul(page.pageSize);
        uint256[] memory result = new uint256[](page.pageRecords);
        for(uint256 i=0; i<page.pageRecords; i++) {
            result[i] = user2cidHash2userActionIndexes[addr][cidHash][start+i];
        }
        return (result, page);
    }

    function addNodeAction(address addr, uint256 tid, ActionType actionType, bytes32 cidHash) external {
        uint256 index = nodeActions.push(NodeAction(now, addr, tid, actionType, cidHash));
        node2nodeActionIndexes[addr].push(index);
        cidHash2nodeActionIndexes[cidHash].push(index);
        node2cidHash2nodeActionIndexes[addr][cidHash].push(index);
    }

    function getNodeHistoryNumber() external view returns (uint256) {
        return nodeActions.length;
    }

    function getNodeHistory(uint256 index) external view returns (NodeAction memory) {
        assert(index <= nodeActions.length);
        return nodeActions[index];
    }

    function getNodeHistoryIndexesByNode(address addr, uint256 pageSize, uint256 pageNumber) external view returns (uint256[] memory, Paging.Page memory) {
        Paging.Page memory page = Paging.getPage(node2nodeActionIndexes[addr].length, pageSize, pageNumber);
        uint256 start = page.pageNumber.sub(1).mul(page.pageSize);
        uint256[] memory result = new uint256[](page.pageRecords);
        for(uint256 i=0; i<page.pageRecords; i++) {
            result[i] = node2nodeActionIndexes[addr][start+i];
        }
        return (result, page);
    }

    function getNodeHistoryIndexesByCidHash(bytes32 cidHash, uint256 pageSize, uint256 pageNumber) external view returns (uint256[] memory, Paging.Page memory) {
        Paging.Page memory page = Paging.getPage(cidHash2nodeActionIndexes[cidHash].length, pageSize, pageNumber);
        uint256 start = page.pageNumber.sub(1).mul(page.pageSize);
        uint256[] memory result = new uint256[](page.pageRecords);
        for(uint256 i=0; i<page.pageRecords; i++) {
            result[i] = cidHash2nodeActionIndexes[cidHash][start+i];
        }
        return (result, page);
    }

    function getNodeHistoryIndexesByNodeAndCidHash(address addr, bytes32 cidHash, uint256 pageSize, uint256 pageNumber) external view returns (uint256[] memory, Paging.Page memory) {
        Paging.Page memory page = Paging.getPage(node2cidHash2nodeActionIndexes[addr][cidHash].length, pageSize, pageNumber);
        uint256 start = page.pageNumber.sub(1).mul(page.pageSize);
        uint256[] memory result = new uint256[](page.pageRecords);
        for(uint256 i=0; i<page.pageRecords; i++) {
            result[i] = node2cidHash2nodeActionIndexes[addr][cidHash][start+i];
        }
        return (result, page);
    }

    function addMonitorAction(address addr, uint256 tid, MonitorActionType actionType, bytes32 cidHash) external {
        uint256 index = monitorActions.push(MonitorAction(now, addr, tid, actionType, cidHash));
        monitor2monitorActionIndexes[addr].push(index);
        cidHash2monitorActionIndexes[cidHash].push(index);
        monitor2cidHash2monitorActionIndexes[addr][cidHash].push(index);
    }

    function getMonitorHistoryNumber() external view returns (uint256) {
        return monitorActions.length;
    }

    function getMonitorHistory(uint256 index) external view returns (MonitorAction memory) {
        assert(index <= monitorActions.length);
        return monitorActions[index];
    }

    function getMonitorHistoryIndexesByMonitor(address addr, uint256 pageSize, uint256 pageNumber) external view returns (uint256[] memory, Paging.Page memory) {
        Paging.Page memory page = Paging.getPage(monitor2monitorActionIndexes[addr].length, pageSize, pageNumber);
        uint256 start = page.pageNumber.sub(1).mul(page.pageSize);
        uint256[] memory result = new uint256[](page.pageRecords);
        for(uint256 i=0; i<page.pageRecords; i++) {
            result[i] = monitor2monitorActionIndexes[addr][start+i];
        }
        return (result, page);
    }

    function getMonitorHistoryIndexesByCidHash(bytes32 cidHash, uint256 pageSize, uint256 pageNumber) external view returns (uint256[] memory, Paging.Page memory) {
        Paging.Page memory page = Paging.getPage(cidHash2monitorActionIndexes[cidHash].length, pageSize, pageNumber);
        uint256 start = page.pageNumber.sub(1).mul(page.pageSize);
        uint256[] memory result = new uint256[](page.pageRecords);
        for(uint256 i=0; i<page.pageRecords; i++) {
            result[i] = cidHash2monitorActionIndexes[cidHash][start+i];
        }
        return (result, page);
    }

    function getMonitorHistoryIndexesByMonitorAndCidHash(address addr, bytes32 cidHash, uint256 pageSize, uint256 pageNumber) external view returns (uint256[] memory, Paging.Page memory) {
        Paging.Page memory page = Paging.getPage(monitor2cidHash2monitorActionIndexes[addr][cidHash].length, pageSize, pageNumber);
        uint256 start = page.pageNumber.sub(1).mul(page.pageSize);
        uint256[] memory result = new uint256[](page.pageRecords);
        for(uint256 i=0; i<page.pageRecords; i++) {
            result[i] = monitor2cidHash2monitorActionIndexes[addr][cidHash][start+i];
        }
        return (result, page);
    }
}
