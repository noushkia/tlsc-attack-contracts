// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.10;

import "forge-std/Test.sol";

import "../src/EscrowCongestion.sol";

contract EscrowCongestionTest is DSTest {
    EscrowCongestion public escrow;

    function setUp() public {
        escrow = new EscrowCongestion();
    }

    function testPartitionedEncoding() public {
        EscrowCongestion.BlockHeader memory header = EscrowCongestion.BlockHeader(
            0xa7494c5e38ffb0bcd279caf1ccbcad3aea47a3cf03213fd1364fbafdca706973, // parentHash
            0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347, // sha3Uncles
            0x0708F87A089a91C65d48721Aa941084648562287, // coinbase
            0xdd7fe7efaf6179cac6c819a3b051bbfff3580f773b6349601104bef344e5c694, // stateRoot
            0xbfaf379ce607121a7b3c0fa6d0a3a078a5f2275004deca653c5aca9ee45156be, // transactionsRoot
            0x026edbbcb487d0f9c81c339b2c7539ab25f316572624db560fe0e54943d24259, // receiptsRoot
            0x0020200080e0000012000010a00002002420000200000000804100001000020000000100000000001000500000000812020088008800088000000800102004000000000009000580000a0008100000200000040000400010000004800000010208000000020000000004000000020c000200000004010400400001100000240000000000000200008042020000100000000000200188000800200041020000000200001000000010020000044808000000000000000000000800000011000000000000220001000020042200000000000000000008000014100000020900200000302000080000000000000000000040c0004040200000000201002000001000, // logsBloom
            8050151966801941, // difficulty
            13000000, // number
            30000000, // gasLimit
            1282538, // gasUsed
            1628632419, // timestamp
            0x73706964657230321105dd27, // extraData
            0xf67e1b0168b37e20c1bddc6580110b1f5df1804f0af65939ed2d223f030338d7, // mixHash
            0x0c00000000, // nonce
            46240053122 // baseFeePerGas
        );

        bytes32 hash = escrow.calculate_block_hash(header);

        assertEq(
            hash,
            0x736048fc56ee5570d18fce0fbad513f8a3cc1de2b18bfecfc8b3663e0bee1570
        );
    }
}
