pragma solidity ^0.5.2;

import "../interfaces/storages/INodeStorage.sol";

library NodeSelector {

    function Storage(address addr) public view returns (INodeStorage) {
        return INodeStorage(addr);
    }

    function selectNodes(address nodeStorageAddress, uint256 size, uint256 count) public view returns (address[] memory) {
        address[] memory onlineNodeAddresses;
        bool finish;
        (onlineNodeAddresses, finish) = Storage(nodeStorageAddress).getAllOnlineNodeAddresses(50, 1);

        if(onlineNodeAddresses.length <= count) {
            return onlineNodeAddresses;
        } else {
            address[] memory nodes = new address[](count);
            for(uint256 i=0; i<count; i++) {
                if(Storage(nodeStorageAddress).getStorageFree(onlineNodeAddresses[i]) >= size) {
                    nodes[i] = onlineNodeAddresses[i];
                }
            }
            return nodes;
        }
    }
}
