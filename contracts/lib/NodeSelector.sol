pragma solidity ^0.5.2;

import "../interfaces/storages/INodeStorage.sol";


library NodeSelector {
    function NodeStorage(address addr) internal view returns (INodeStorage) {
        return INodeStorage(addr);
    }

    function selectNodes(address nodeStorageAddr, uint256 count) internal view returns (address[] memory nodes, bool success) {
        address[] memory allOnlineNodeAddresses = NodeStorage(nodeStorageAddr).getAllOnlineNodeAddresses();
        return (allOnlineNodeAddresses, true);
    }
}
