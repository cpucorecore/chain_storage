pragma solidity ^0.5.2;
pragma experimental ABIEncoderV2;

interface IUser {
    function register(address addr, string calldata ext) external;
    function deRegister(address addr) external;
    function setExt(address addr, string calldata ext) external;
    function changeSpace(address addr, uint256 size) external;
    function addFile(address addr, string calldata cid, uint256 size, uint256 duration, string calldata ext) external;
    function callbackFinishAddFile(address owner, address node, string calldata cid) external;
    function callbackFailAddFile(address owner, string calldata cid) external;
    function deleteFile(address addr, string calldata cid) external;
    function callbackFinishDeleteFile(address owner, address node, string calldata cid) external;
    function setFileExt(address addr, string calldata cid, string calldata ext) external;
    function setFileDuration(address addr, string calldata cid, uint256 duration) external;
}
