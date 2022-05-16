pragma solidity ^0.5.2;
pragma experimental ABIEncoderV2;

interface IUser {
    function register(address addr, string calldata ext) external;
    function deRegister(address addr) external;
    function setExt(address addr, string calldata ext) external;
    function changeSpace(address addr, uint256 size) external;
    function setFileExt(address addr, string calldata cid, string calldata ext) external;
    function setFileDuration(address addr, string calldata cid, uint256 duration) external;
    function addFile(address addr, string calldata cid, uint256 duration, string calldata ext) external;
    function deleteFile(address addr, string calldata cid) external;

    function onAddFileFinish(address owner, string calldata cid, uint256 size) external;
    function onAddFileFail(address owner, string calldata cid) external;
    function onDeleteFileFinish(address owner, string calldata cid, uint256 size) external;
}
