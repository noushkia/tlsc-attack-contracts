// SPDX-License-Identifier: GPL-3.0

// Layout of Contract:
// Version
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
 * @dev The only transaction in the block and the reward payout system
 */
contract EscrowCongestion {
    // Store block hashes in case the congestion period is higher than 256 blocks
    mapping(uint256 => bytes32) private block_hash;

    // The addresses of the miners who mined the congested blocks
    mapping(uint256 => address) private block_reward_addresses;

    // The transaction roots for each block (initialized in contract creation)
    mapping(uint256 => bytes32) public block_tx_roots;

    // The block reward for the congested blocks
    uint256 public block_reward = 1 ether;

    // The start block of the congested blocks
    uint256 public start_block = 0;

    // The end block of the congested blocks
    uint256 public end_block = 0;

    // State variable to keep track of congested blocks
    mapping(uint256 => bool) private congested_blocks;

    // Variable to keep track of the count of congested blocks
    uint256 private congested_block_count;

    // [0x16b6ff83df3ef14f614c70ac29e8a05d102c6bed0e5882c284abf0120b89529c], 10029487, 10029488, 10000000000000000
    
    // The constructor will initialize the expected transaction roots for each block
    constructor(
        bytes32[] memory _block_tx_roots,
        uint256 _start_block,
        uint256 _end_block,
        uint256 _block_reward
    ) {
        require(_start_block > block.number, "Invalid block range");
        // ensure the length of _block_tx_roots is equal to the block range
        require(
            _block_tx_roots.length == _end_block - _start_block,
            "The length of the block tx roots must be equal to the block range"
        );

        // ensure the block range is not empty
        require(_start_block < _end_block, "The block range is empty");

        // set the block reward
        block_reward = _block_reward;

        // set the block range
        start_block = _start_block;
        end_block = _end_block;

        // set the block tx roots
        for (uint i = _start_block; i < _end_block; i++) {
            block_tx_roots[i] = _block_tx_roots[i-_start_block];
        }
    }

    // This transaction must be the only transaction executed in the block.
    // It will store the current blocks reward address and after correct
    // verifications, the miner can claim the reward.
    // 66,038 gas?
    function congest() external {
        // Store the previous block hash in case the congestion period is over 256 blocks
        block_hash[block.number - 1] = blockhash(block.number - 1);

        // Store the current block reward address for future payments
        block_reward_addresses[block.number] = block.coinbase;
    }

    // Pay the miner the fixed reward for congesting the block.
    // The miner can claim the reward if the block is congested and the
    // transaction is the only one in the block.
    // All the miners in the block range must post this transactions.
    // When the block range is verified, the rewards are paid out.
    function claim_reward(
        bytes[] calldata pre_root_encoding,
        bytes[] calldata post_root_encoding,
        uint256 _block_number
    ) external {
        bytes32 claimed_hash = compute_claimed_block_hash(
            pre_root_encoding,
            block_tx_roots[_block_number],
            post_root_encoding
        );
        bool hash_is_equal = claimed_hash == block_hash[_block_number];

        // Ensure the block hash is equal to the claimed hash i.e. there is only the congest transaction in the block
        require(hash_is_equal, "Block hash is not equal to the real hash");

        if (!congested_blocks[_block_number]) {
            congested_blocks[_block_number] = true;
            congested_block_count++;
        }

        if (congested_block_count == end_block - start_block) {
            pay_rewards();
        }
    }

    // Pay the miners the fixed(could be dynamic) reward for congesting the block.
    function pay_rewards() public payable {
        // iterate over block_reward_addresses and pay the miners
        for (uint i = start_block; i < end_block; i++) {
            address coinbase = block_reward_addresses[i];

            // Update the block_reward_addresses to prevent double payments
            block_reward_addresses[i] = address(0);

            // Pay the miner the reward
            payable(coinbase).transfer(block_reward);
        }
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
