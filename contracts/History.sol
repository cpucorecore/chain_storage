// SPDX-License-Identifier: MIT
pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import './lib/SafeMath.sol';
import './lib/Paging.sol';
import './base/Importable.sol';
import './interfaces/IHistory.sol';

contract History is Importable, IHistory {
    using SafeMath for uint256;

    UserAction[] private userActions;
    mapping(address=>uint256[]) private user2userActionIndexs;
    mapping(bytes32=>uint256[]) private cidHash2userActionIndexs;
    mapping(address=>mapping(bytes32=>uint256[])) user2cidHash2userActionIndex;

    NodeAction[] private nodeActions;
    mapping(address=>uint256[]) private node2nodeActionIndexs;
    mapping(bytes32=>uint256[]) private cidHash2nodeActionIndexs;
    mapping(address=>mapping(bytes32=>uint256[])) node2cidHash2nodeActionIndex;

    MonitorAction[] private monitorActions;
    mapping(address=>uint256[]) private monitor2monitorActionIndexs;
    mapping(bytes32=>uint256[]) private cidHash2monitorActionIndexs;
    mapping(address=>mapping(bytes32=>uint256[])) monitor2cidHash2monitorActionIndex;

    constructor(IResolver _resolver) public Importable(_resolver) {
        setContractName(CONTRACT_HISTORY);
        imports = [
            CONTRACT_SETTING
        ];
    }

    function addUserAction(address addr, ActionType actionType, bytes32 cidHash) external {
        uint256 index = userActions.push(UserAction(now, addr, actionType, cidHash));
        user2userActionIndexs[addr].push(index);
        cidHash2userActionIndexs[cidHash].push(index);
        user2cidHash2userActionIndex[addr][cidHash].push(index);
    }

    function getUserHistory(uint256 pageSize, uint256 pageNumber) external view returns (UserAction[] memory, Paging.Page memory) {
        Paging.Page memory page = Paging.getPage(userActions.length, pageSize, pageNumber);
        uint256 start = page.pageNumber.sub(1).mul(page.pageSize);
        UserAction[] memory result = new UserAction[](page.pageRecords);
        for(uint256 i=0; i<page.pageRecords; i++) {
            result[i] = userActions[start+i];
        }
        return (result, page);
    }

    function getUserHistoryByUser(address addr, uint256 pageSize, uint256 pageNumber) external view returns (UserAction[] memory, Paging.Page memory) {
        Paging.Page memory page = Paging.getPage(user2userActionIndexs[addr].length, pageSize, pageNumber);
        uint256 start = page.pageNumber.sub(1).mul(page.pageSize);
        UserAction[] memory result = new UserAction[](page.pageRecords);
        for(uint256 i=0; i<page.pageRecords; i++) {
            result[i] = userActions[user2userActionIndexs[addr][start+i]];
        }
        return (result, page);
    }

    function getUserHistoryByCidHash(bytes32 cidHash, uint256 pageSize, uint256 pageNumber) external view returns (UserAction[] memory, Paging.Page memory) {
        Paging.Page memory page = Paging.getPage(cidHash2userActionIndexs[cidHash].length, pageSize, pageNumber);
        uint256 start = page.pageNumber.sub(1).mul(page.pageSize);
        UserAction[] memory result = new UserAction[](page.pageRecords);
        for(uint256 i=0; i<page.pageRecords; i++) {
            result[i] = userActions[cidHash2userActionIndexs[cidHash][start+i]];
        }
        return (result, page);
    }

    function getUserHistoryByUserAndCidHash(address addr, bytes32 cidHash, uint256 pageSize, uint256 pageNumber) external view returns (UserAction[] memory, Paging.Page memory) {
        Paging.Page memory page = Paging.getPage(user2cidHash2userActionIndex[addr][cidHash].length, pageSize, pageNumber);
        uint256 start = page.pageNumber.sub(1).mul(page.pageSize);
        UserAction[] memory result = new UserAction[](page.pageRecords);
        for(uint256 i=0; i<page.pageRecords; i++) {
            result[i] = userActions[user2cidHash2userActionIndex[addr][cidHash][start+i]];
        }
        return (result, page);
    }

    function addNodeAction(address addr, uint256 tid, ActionType actionType, bytes32 cidHash) external {
        uint256 index = nodeActions.push(NodeAction(now, addr, tid, actionType, cidHash));
        node2nodeActionIndexs[addr].push(index);
        cidHash2nodeActionIndexs[cidHash].push(index);
        node2cidHash2nodeActionIndex[addr][cidHash].push(index);
    }

    function getNodeHistory(uint256 pageSize, uint256 pageNumber) external view returns (NodeAction[] memory, Paging.Page memory) {
        Paging.Page memory page = Paging.getPage(nodeActions.length, pageSize, pageNumber);
        uint256 start = page.pageNumber.sub(1).mul(page.pageSize);
        NodeAction[] memory result = new NodeAction[](page.pageRecords);
        for(uint256 i=0; i<page.pageRecords; i++) {
            result[i] = nodeActions[start+i];
        }
        return (result, page);
    }

    function getNodeHistoryByNode(address addr, uint256 pageSize, uint256 pageNumber) external view returns (NodeAction[] memory, Paging.Page memory) {
        Paging.Page memory page = Paging.getPage(node2nodeActionIndexs[addr].length, pageSize, pageNumber);
        uint256 start = page.pageNumber.sub(1).mul(page.pageSize);
        NodeAction[] memory result = new NodeAction[](page.pageRecords);
        for(uint256 i=0; i<page.pageRecords; i++) {
            result[i] = nodeActions[node2nodeActionIndexs[addr][start+i]];
        }
        return (result, page);
    }

    function getNodeHistoryByCidHash(bytes32 cidHash, uint256 pageSize, uint256 pageNumber) external view returns (NodeAction[] memory, Paging.Page memory) {
        Paging.Page memory page = Paging.getPage(cidHash2nodeActionIndexs[cidHash].length, pageSize, pageNumber);
        uint256 start = page.pageNumber.sub(1).mul(page.pageSize);
        NodeAction[] memory result = new NodeAction[](page.pageRecords);
        for(uint256 i=0; i<page.pageRecords; i++) {
            result[i] = nodeActions[cidHash2nodeActionIndexs[cidHash][start+i]];
        }
        return (result, page);
    }

    function getNodeHistoryByNodeAndCidHash(address addr, bytes32 cidHash, uint256 pageSize, uint256 pageNumber) external view returns (NodeAction[] memory, Paging.Page memory) {
        Paging.Page memory page = Paging.getPage(node2cidHash2nodeActionIndex[addr][cidHash].length, pageSize, pageNumber);
        uint256 start = page.pageNumber.sub(1).mul(page.pageSize);
        NodeAction[] memory result = new NodeAction[](page.pageRecords);
        for(uint256 i=0; i<page.pageRecords; i++) {
            result[i] = nodeActions[user2cidHash2userActionIndex[addr][cidHash][start+i]];
        }
        return (result, page);
    }

    function addMonitorAction(address addr, uint256 tid, MonitorActionType actionType, bytes32 cidHash) external {
        uint256 index = monitorActions.push(MonitorAction(now, addr, tid, actionType, cidHash));
        monitor2monitorActionIndexs[addr].push(index);
        cidHash2monitorActionIndexs[cidHash].push(index);
        monitor2cidHash2monitorActionIndex[addr][cidHash].push(index);
    }

    function getMonitorHistory(uint256 pageSize, uint256 pageNumber) external view returns (MonitorAction[] memory, Paging.Page memory) {
        Paging.Page memory page = Paging.getPage(monitorActions.length, pageSize, pageNumber);
        uint256 start = page.pageNumber.sub(1).mul(page.pageSize);
        MonitorAction[] memory result = new MonitorAction[](page.pageRecords);
        for(uint256 i=0; i<page.pageRecords; i++) {
            result[i] = monitorActions[start+i];
        }
        return (result, page);
    }

    function getMonitorHistoryByMonitor(address addr, uint256 pageSize, uint256 pageNumber) external view returns (MonitorAction[] memory, Paging.Page memory) {
        Paging.Page memory page = Paging.getPage(monitor2monitorActionIndexs[addr].length, pageSize, pageNumber);
        uint256 start = page.pageNumber.sub(1).mul(page.pageSize);
        MonitorAction[] memory result = new MonitorAction[](page.pageRecords);
        for(uint256 i=0; i<page.pageRecords; i++) {
            result[i] = monitorActions[monitor2monitorActionIndexs[addr][start+i]];
        }
        return (result, page);
    }

    function getMonitorHistoryByCidHash(bytes32 cidHash, uint256 pageSize, uint256 pageNumber) external view returns (MonitorAction[] memory, Paging.Page memory) {
        Paging.Page memory page = Paging.getPage(cidHash2monitorActionIndexs[cidHash].length, pageSize, pageNumber);
        uint256 start = page.pageNumber.sub(1).mul(page.pageSize);
        MonitorAction[] memory result = new MonitorAction[](page.pageRecords);
        for(uint256 i=0; i<page.pageRecords; i++) {
            result[i] = monitorActions[cidHash2monitorActionIndexs[cidHash][start+i]];
        }
        return (result, page);
    }

    function getMonitorHistoryByMonitorAndCidHash(address addr, bytes32 cidHash, uint256 pageSize, uint256 pageNumber) external view returns (MonitorAction[] memory, Paging.Page memory) {
        Paging.Page memory page = Paging.getPage(monitor2cidHash2monitorActionIndex[addr][cidHash].length, pageSize, pageNumber);
        uint256 start = page.pageNumber.sub(1).mul(page.pageSize);
        MonitorAction[] memory result = new MonitorAction[](page.pageRecords);
        for(uint256 i=0; i<page.pageRecords; i++) {
            result[i] = monitorActions[monitor2cidHash2monitorActionIndex[addr][cidHash][start+i]];
        }
        return (result, page);
    }
}
