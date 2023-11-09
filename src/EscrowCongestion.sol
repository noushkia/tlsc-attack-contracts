// SPDX-License-Identifier: GPL-3.0

// Layout of Contract:
// version
// State variables
// Functions

// Layout of Functions:
// constructor
// external
// public
// private

pragma solidity <0.9.0;

/**
 * @title Escrow Congestor
 * @dev The only transaction in the block
 */
contract EscrowCongestion {
    // The addresses of the miners who mined the congested blocks
    mapping(uint256 => address) public block_reward_addresses;

    // The transaction roots for each block (initialized in contract creation)
    mapping(uint256 => bytes32) public block_tx_roots;

    // The block reward for the congested blocks
    uint256 public block_reward = 1 ether;

    // The constructor will initialize the expected transaction roots for each block
    constructor(bytes32[] memory _block_tx_roots) {
        for (uint i = 0; i < _block_tx_roots.length; i++) {
            block_tx_roots[i] = _block_tx_roots[i];
        }
    }

    // Pay the miner the fixed reward for congesting the block.
    // The miner can claim the reward if the block is congested and the
    // transaction is the only one in the block.
    function claim_reward(
        bytes[] calldata pre_root_encoding,
        bytes[] calldata post_root_encoding,
        uint256 _block_number
    ) external payable {
        require(
            block_reward_addresses[_block_number] == msg.sender,
            "Only the proposer can claim the reward"
        );

        bytes32 claimed_hash = compute_claimed_block_hash(
            pre_root_encoding,
            block_tx_roots[_block_number],
            post_root_encoding
        );
        bool hash_is_equal = claimed_hash == blockhash(_block_number);

        // Ensure the block hash is equal to the claimed hash i.e. there is only the congest transaction in the block
        require(hash_is_equal, "Block hash is not equal to the real hash");

        // Reset the block reward address to prevent double claiming
        block_reward_addresses[_block_number] = address(0);

        // Pay the miner the reward
        payable(block_reward_addresses[_block_number]).transfer(block_reward);
    }

    // This transaction must be the only transaction executed in the block.
    // It will store the current blocks reward address and after correct
    // verifications, the miner can claim the reward.
    function congest() public {
        block_reward_addresses[block.number] = block.coinbase;
    }

    function compute_claimed_block_hash(
        bytes[] calldata pre_root_encoding,
        bytes32 tx_root,
        bytes[] calldata post_root_encoding
    ) private pure returns (bytes32) {
        bytes memory pre_encoding = abi.encodePacked(pre_root_encoding[0]);
        for (uint i = 1; i < pre_root_encoding.length; i++) {
            pre_encoding = abi.encodePacked(pre_encoding, pre_root_encoding[i]);
        }

        bytes memory post_encoding = abi.encodePacked(post_root_encoding[0]);
        for (uint i = 1; i < post_root_encoding.length; i++) {
            post_encoding = abi.encodePacked(
                post_encoding,
                post_root_encoding[i]
            );
        }

        bytes memory encoded_block_header = abi.encodePacked(
            pre_encoding,
            tx_root,
            post_encoding
        );
        return keccak256(encoded_block_header);
    }
}
