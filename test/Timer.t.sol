// // SPDX-License-Identifier: UNLICENSED

// pragma solidity ^0.8.10;

// import "forge-std/Test.sol";

// import "../src/Timer.sol";

// interface CheatCodes {
//     function warp(uint256) external;
// }

// contract TimerTest is DSTest {
//     // HEVM_ADDRESS is the pre-defined contract that contains the cheatcodes

//     CheatCodes constant cheats = CheatCodes(HEVM_ADDRESS);

//     Timer public t;

//     address toAddr = 0x1234567890123456789012345678901234567890;

//     function setUp() public {
//         t = new Timer();

//         t.queueMint(toAddr, 100, 0 + 600);
//     }

//     // Ensure you can't double queue

//     function testFailDoubleQueue() public {
//         t.queueMint(toAddr, 100, 0 + 600);
//     }

//     // Ensure you can't queue in the past

//     function testFailPastQueue() public {
//         t.queueMint(toAddr, 100, 45);
//     }

//     // Minting should work after the time has passed

//     function testMintAfterTen() public {
//         uint256 targetCall = 10;

//         t.updateCallCount(targetCall);


//         t.executeMint(toAddr, 100, targetCall);
//     }

//     // Minting should fail if you mint too soon

//     function testFailMintNow() public {
//         t.executeMint(toAddr, 100, 2);
//     }

//     // Minting should fail if you didn't queue

//     function testFailMintNonQueued() public {
//         t.executeMint(toAddr, 999, 11);
//     }

//     // Minting should fail if try to mint twice

//     function testFailDoubleMint() public {
//         uint256 targetCall = t.getCallCount() + 10;

//         t.updateCallCount(targetCall);

//         t.executeMint(toAddr, 100, targetCall);

//         t.updateCallCount(targetCall + 1);

//         t.executeMint(toAddr, 100, targetCall + 2);
//     }

//     // Minting should fail if you try to mint too late

//     function testFailLateMint() public {
//         uint256 targetCall = t.getCallCount() + 10;

//         t.updateCallCount(targetCall);

//         t.executeMint(toAddr, 100, targetCall);
//     }
// }
