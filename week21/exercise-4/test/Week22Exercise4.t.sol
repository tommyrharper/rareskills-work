// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Week22Exercise4} from "../src/Week22Exercise4.sol";

contract Week22Exercise4Test is Test {
    Week22Exercise4 public exercise;

    function setUp() public {
        exercise = new Week22Exercise4();
    }

    function test_Attack() public {

    }
}
