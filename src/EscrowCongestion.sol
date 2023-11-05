// SPDX-License-Identifier: GPL-3.0

pragma solidity <0.9.0;

/**
 * @title Escrow Congestor
 * @dev The only transaction in the block
 */
contract EscrowCongestion {
    // todo: add PoS fields for blocks since the merge (15537394)
    struct BlockHeader {
        bytes32 parentHash;
        bytes32 uncleHash;
        address coinbase;
        bytes32 stateRoot;
        bytes32 txRoot; // note: this will be stored in the contract and should not be in the function arguments
        bytes32 receiptRoot;
        bytes32 logsBloom;
        uint256 difficulty;
        uint256 number;
        uint256 gasLimit;
        uint256 gasUsed;
        uint256 timestamp;
        bytes32 extraData;
        bytes32 mixHash;
        uint256 nonce;
        uint256 baseFeePerGas; // EIP-1559 blocks (since block 12_965_000)
    }

    // The addresses of the miners who mined the congested blocks
    mapping(uint256 => address) public block_reward_addresses;

    // The transaction roots for each block (initialized in contract creation)
    mapping(uint256 => bytes32) public block_tx_roots;

    // The block reward for the congested blocks
    uint256 public block_reward = 1 ether;

    // Modifier to ensure only the proposer of the block can claim the reward
    modifier only_proposer(uint256 _block_number) {
        require(block_reward_addresses[_block_number] == block.coinbase);
        _;
    }

    // Calculates the hash of the block given block headers
    function calculate_block_hash(
        BlockHeader memory _block_header
        // uint256 block_number
    ) public pure returns (bytes32) {
        // encodings are broken down so that the stack does not overflow
        bytes memory pre_tx_root_encoding = abi.encodePacked(
            _block_header.parentHash,
            _block_header.uncleHash,
            _block_header.coinbase,
            _block_header.stateRoot
        );
        bytes memory post_tx_root_encoding = abi.encodePacked(
            _block_header.receiptRoot,
            _block_header.logsBloom,
            _block_header.difficulty,
            _block_header.number,
            _block_header.gasLimit,
            _block_header.gasUsed,
            _block_header.timestamp,
            _block_header.extraData,
            _block_header.mixHash,
            _block_header.nonce,
            _block_header.baseFeePerGas
        );
        bytes memory encoded_block_header = abi.encodePacked(
            pre_tx_root_encoding,
            _block_header.txRoot, // debug
            // block_tx_roots[block_number], // real
            post_tx_root_encoding
        );
        bytes32 calculated_hash = keccak256(encoded_block_header);
        return calculated_hash;
    }

    // Checks the calculated hash with the real block hash
    // todo: check if you can pack the arguments into a struct
    function verify_miner_block(
        bytes32 _block_hash,  // note: change to block_number
        BlockHeader memory _block_header
    ) public view returns (bool) {
        bytes32 calculated_hash = calculate_block_hash(
            _block_header
        );
        return calculated_hash == _block_hash;
    }

    // This transaction must be the only transaction executed in the block.
    // It will store the current blocks reward address and after correct
    // verifications, the miner can claim the reward.
    function congest() public {
        block_reward_addresses[block.number] = block.coinbase;
    }

    // Pay the miner the fixed reward for congesting the block.
    // The miner can claim the reward if the block is congested and the
    // transaction is the only one in the block.
    function claim_reward(
        uint256 _block_number
    ) public payable only_proposer(_block_number) {
        // TODO: Add a block number lock to ensure the reward is only claimable after a certain time
        // TODO: Check the range of blocks are congested
        // How to check the range of blocks are congested?
        //      - Check if the given range of block rewards are in the mapping
        // How to check the transaction is the only one in the block?
        //      -
        payable(block_reward_addresses[_block_number]).transfer(block_reward);
    }
}
