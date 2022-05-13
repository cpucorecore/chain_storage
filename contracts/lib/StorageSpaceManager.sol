pragma solidity ^0.5.2;

import "./SafeMath.sol";

library StorageSpaceManager {
    using SafeMath for uint256;

    struct StorageSpace {
        uint256 used;
        uint256 total;
    }

    function useSpace(StorageSpace storage this, uint256 size) internal {
        require(this.used.add(size) <= this.total, "SSM:ne"); // space not enough
        this.used += size;
    }

    function unUseSpace(StorageSpace storage this, uint256 size) internal {
        require(size <= this.used, "SSM:oou"); // // out of used
        this.used -= size;
    }

    function availableSpace(StorageSpace storage this) internal view returns (uint256) {
        if(this.used > this.total) return 0;
        return this.total.sub(this.used);
    }
}
