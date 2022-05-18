pragma solidity ^0.5.2;

import "./SafeMath.sol";

library StorageSpaceManager {
    using SafeMath for uint256;

    struct StorageSpace {
        uint256 used;
        uint256 total;
    }

    function useSpace(StorageSpace storage self, uint256 size) internal { // TODO add flag: can use more space
        require(self.used.add(size) <= self.total, "SSM:useSpace space not enough");
        self.used += size;
    }

    function unUseSpace(StorageSpace storage self, uint256 size) internal {
        require(size <= self.used, "SSM:unUseSpace out of used");
        self.used -= size;
    }

    function availableSpace(StorageSpace storage self) internal view returns (uint256) {
        if(self.used > self.total) return 0;
        return self.total.sub(self.used);
    }
}
