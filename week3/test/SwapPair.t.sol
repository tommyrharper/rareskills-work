// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/SwapPair.sol";

contract SwapPairTest is Test {
    SwapPair public swapPair;

    function setUp() public {
        swapPair = new SwapPair();
    }

    function testSwapPair() public {}
}
