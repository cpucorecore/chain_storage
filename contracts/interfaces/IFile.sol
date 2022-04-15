pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

interface IFile {
    function addFile(string calldata cid, uint size, address owner) external;
    function deleteFile(string calldata cid, address owner) external returns(bool);

    function fileAdded(string calldata cid, string calldata pid) external;
    function fileDeleted(string calldata cid, string calldata pid) external;
}
