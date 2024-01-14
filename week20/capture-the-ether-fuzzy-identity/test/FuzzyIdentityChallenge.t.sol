// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {FuzzyIdentityChallenge} from "../src/FuzzyIdentityChallenge.sol";

contract FuzzyIdentityChallengeTest is Test {
    FuzzyIdentityChallenge public fuzzy;

    function setUp() public {
        fuzzy = new FuzzyIdentityChallenge();
    }

    function test_Fuzzy() public {

    }
}
