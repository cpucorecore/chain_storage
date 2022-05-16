pragma solidity ^0.5.2;

interface IUserCallback {
    function callbackFinishAddFile(address owner, string calldata cid, uint256 size) external;
    function callbackFailAddFile(address owner, string calldata cid) external;
    function callbackFinishDeleteFile(address owner, string calldata cid, uint256 size) external;
}
