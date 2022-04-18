pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

interface IUser {
    function register(address addr, string calldata ext) external;
    function deRegister(address addr) external;
    function exist(address addr) external returns(bool);
    function addFile(address addr, string calldata cid, uint256 size, uint256 duration, string calldata ext) external;
    function deleteFile(address addr, string calldata cid) external;
    function changeSpace(address addr, uint256 size) external;// only admin
    function cids(address addr) external returns(string[] memory);
    function storageInfo(address addr) external returns(uint256, uint256); // (used, space)
}
