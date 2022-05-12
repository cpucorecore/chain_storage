pragma solidity ^0.5.2;

import "../interfaces/storages/INodeStorageViewer.sol";

library NodeSelector {

    function StorageViewer(address addr) public view returns (INodeStorageViewer) {
        return INodeStorageViewer(addr);
    }

    function selectNodes(address nodeStorageAddress, uint256 size, uint256 count) public view returns (address[] memory) {
        address[] memory onlineNodeAddresses;
        bool finish;
        (onlineNodeAddresses, finish) = StorageViewer(nodeStorageAddress).getAllOnlineNodeAddresses(50, 1);

        if(onlineNodeAddresses.length <= count) {
            return onlineNodeAddresses;
        } else {
            address[] memory nodes = new address[](count);
            for(uint256 i=0; i<count; i++) {
                if(StorageViewer(nodeStorageAddress).getStorageFree(onlineNodeAddresses[i]) >= size) {
                    nodes[i] = onlineNodeAddresses[i];
                }
            }
            return nodes;
        }
    }
}
