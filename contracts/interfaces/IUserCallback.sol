pragma solidity ^0.5.2;

interface IUserCallback {
    function callbackFinishAddFile(address owner, address node, string calldata cid) external;
    function callbackFailAddFile(address owner, string calldata cid) external;
    function callbackFinishDeleteFile(address owner, address node, string calldata cid) external;
}
