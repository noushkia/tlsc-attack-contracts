// SPDX-License-Identifier: GPL-3.0

pragma solidity <0.9.0;

/**
 * @title Basic Congestor
 * @dev Take up a whole block
 */
contract BasicCongestor {
    function congest() public view {
        // This transaction must be the only transaction executed in the block.
        // Note 1: We can use block.gas_limit instead of 30_000_000 to ensure the 
        // transaction will be the only one in the block
        // Note 2: We can also use a do while (gasLeft() > x) loop to ensure 
        // transaction success. In this case, state updates are also allowed.
        require(gasleft() >= 30_000_000 - 300);
        while (true) {}
    }
}
