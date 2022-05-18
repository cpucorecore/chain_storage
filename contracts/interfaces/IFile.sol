pragma solidity ^0.5.2;
pragma experimental ABIEncoderV2;

interface IFile {
    function addFile(string calldata cid, address userAddress) external returns (bool finish);
    function onNodeAddFileFinish(address nodeAddress, address userAddress, string calldata cid, uint256 size) external;
    function onAddFileFail(address userAddress, string calldata cid) external;

    function deleteFile(string calldata cid, address userAddress) external returns (bool finish);
    function onNodeDeleteFileFinish(address nodeAddress, address userAddress, string calldata cid) external;

    function getSize(string calldata cid) external view returns (uint256);
}
