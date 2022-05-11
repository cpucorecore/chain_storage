pragma solidity ^0.5.2;

interface IUserFileHandler {
    function addFile(address addr, string calldata cid, uint256 size, uint256 duration, string calldata ext) external;
    function callbackFinishAddFile(address owner, address node, string calldata cid) external;
    function callbackFailAddFile(address owner, string calldata cid) external;
    function deleteFile(address addr, string calldata cid) external;
    function callbackFinishDeleteFile(address owner, address node, string calldata cid) external;
}
