// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Week22Exercise3} from "../src/Week22Exercise3.sol";

contract Week22Exercise3Test is Test {
    Week22Exercise3 internal exercise;

    uint256 privateKey =
        0x1010101010101010101010101010101010101010101010101010101010101010;
    address internal owner;

    function setUp() public {
        owner = vm.addr(privateKey);
        exercise = new Week22Exercise3();
    }

    function test_attack() public {
        // just passes with invalid signature as owner is not yet set
        exercise.claimAirdrop(100, address(this), 0, bytes32(0), bytes32(0));
    }
}
