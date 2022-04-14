pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import "../lib/Paging.sol";

interface IHistory {

    enum Action {
        Add,
        Delete
    }

    struct FileAction {
        address user;
        string cid;
        Action action;
    }

    function addFileHistory() external;
    function getFileHistory(uint256 pageSize, uint256 pageNumber) external returns(FileAction[] memory, Paging.Page memory);
    function addNodeHistory() external;
    function getNodeHistory(uint256 pageSize, uint256 pageNumber) external;
}
