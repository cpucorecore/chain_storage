pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

interface IUser {
    function register(uint256 space) external;
    function deRegister() external;
    function exist(address addr) external returns(bool);
    function addFile(string calldata cid, uint256 size, uint256 duration, string calldata ext) external;
    function deleteFile(string calldata cid) external;
    function changeSpace(address addr, uint256 size) external;// only admin
    function cids() external returns(string[] memory);
    function storageInfo() external returns(uint256, uint256); // (storageUsed, storageSpace)
}
