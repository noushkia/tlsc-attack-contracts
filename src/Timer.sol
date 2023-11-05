// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.10;

contract Timer {
    function timelock(uint _timestamp) public view returns (int) {
        require(block.timestamp >= _timestamp);
        return 2 + 2;
    }
}
