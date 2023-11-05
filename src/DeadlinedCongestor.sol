// SPDX-License-Identifier: GPL-3.0

pragma solidity <0.9.0;

/**
 * @title Multiple Blocks Congestor
 * @dev Take up a whole block
 */
contract DeadlinedCongestor {
    uint64 target_block_number = 15_000_000;

    function congest() public {
        // This transaction must be the only transaction executed in the block.
        require(gasleft() >= 30_000_000 - 300);
        // This transaction must be executed only before a certain block
        // i.e. only congest up to target_block_number
        require(block.number < target_block_number);
        while (true) {}
    }
}
