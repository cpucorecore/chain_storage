pragma solidity ^0.5.2;
pragma experimental ABIEncoderV2;

import "./storages/ITaskStorage.sol";

interface ITask {
    function exist(uint256 tid) external view returns (bool);
    function getCurrentTid() external view returns (uint256);
    function getNodeMaxTid(address addr) external view returns (uint256);
    function isOver(uint256 tid) external view returns (bool);
    function issueTask(ITaskStorage.Action action, address owner, string calldata cid, address node, uint256 size) external returns (uint256);

    function getOwner(uint256 tid) external view returns (address);
    function getAction(uint256 tid) external view returns (ITaskStorage.Action);
    function getNode(uint256 tid) external view returns (address);
    function getSize(uint256 tid) external view returns (uint256);
    function getCid(uint256 tid) external view returns (string memory);
    function getCreateBlockNumber(uint256 tid) external view returns (uint256);

    function getStatus(uint256 tid) external view returns (ITaskStorage.Status);
    function getCreateTime(uint256 tid) external view returns (uint256);
    function getAcceptTime(uint256 tid) external view returns (uint256);
    function getAcceptTimeoutTime(uint256 tid) external view returns (uint256);
    function getFinishTime(uint256 tid) external view returns (uint256);
    function getFailTime(uint256 tid) external view returns (uint256);
    function getTimeoutTime(uint256 tid) external view returns (uint256);
    function getStatusAndTime(uint256 tid) external view returns (ITaskStorage.Status, uint256);
    function setStatusAndTime(uint256 tid, ITaskStorage.Status status, uint256 time) external;

    function getAddFileTaskProgress(uint256 tid) external view returns (uint256, uint256, uint256, uint256, uint256, uint256);

    function acceptTask(address node, uint256 tid) external; // for storage server
    function finishTask(uint256 tid) external; // for Node()
    function failTask(uint256 tid) external; // for Node()
    function acceptTaskTimeout(uint256 tid) external; // for Monitor()-->Node()
    function taskTimeout(uint256 tid) external; // for Monitor()-->Node()
    function reportAddFileProgressBySize(address addr, uint256 tid, uint256 size) external; // for storage server
    function reportAddFileProgressByPercentage(address addr, uint256 tid, uint256 percentage) external; // for storage server
}
