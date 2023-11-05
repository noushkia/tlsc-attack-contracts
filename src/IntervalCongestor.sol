// SPDX-License-Identifier: GPL-3.0

pragma solidity <0.9.0;

/**
 * @title Multiple Blocks Congestor
 * @dev Take up a whole block
 */
contract IntervalCongestor {
    uint256 target_block_number = 15_000_010;
    uint256 last_congested_block_number = 15_000_005;

    function congested_current_block() public {
        // Need to make sure this is called in the same congested block...
        last_congested_block_number = block.number;
    }

    function congest() public view {
        // This transaction must be the only transaction executed in the block.
        require(gasleft() >= 30_000_000 - 22800);
        // This transaction must be executed only before a certain block
        // i.e. only congest up to target_block_number
        uint256 curr_block_number = block.number;
        require(curr_block_number < target_block_number);
        require(curr_block_number == last_congested_block_number);
        while (true) {} 
        // Note: Do while gasLeft is also possible...
    }
}
