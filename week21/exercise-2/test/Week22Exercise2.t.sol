// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Week22Exercise2} from "../src/Week22Exercise2.sol";

contract Week22Exercise2Test is Test {
    Week22Exercise2 public exercise;

    function setUp() public {
        exercise = new Week22Exercise2();
    }

    /// @dev I solved this by following these steps:
    /// 1) searched on etherscan for address 0x0000000cCC7439F4972897cCd70994123e0921bC
    /// 2) found it active on Optimism: https://optimistic.etherscan.io/address/0x0000000ccc7439f4972897ccd70994123e0921bc
    /// 3) went through the transactions and found this one: https://optimistic.etherscan.io/tx/0x08e18539b6a2b45c74aa3eb4bc769a173baf87b3373437123c9498d72f02c2e2
    /// 4) noticed that it went to this contract: https://optimistic.etherscan.io/address/0x9564351ec4620b541d474b67c267f9ac307fc59d
    /// 5) stole the calldata from the tx (message and signature)
    function test_attack() public {
        string memory message = "attack at dawn";
        bytes memory signature = getSignature();

        exercise.challenge(message, signature);
    }

    function getSignature() internal returns (bytes memory) {
        bytes32 r = 0xe5d0b13209c030a26b72ddb84866ae7b32f806d64f28136cb5516ab6ca15d3c4;
        bytes32 s = 0x38d9e7c79efa063198fda1a5b48e878a954d79372ed71922003f847029bf2e75;
        uint8 v = 27;
        return abi.encodePacked(r, s, v);
    }
}
