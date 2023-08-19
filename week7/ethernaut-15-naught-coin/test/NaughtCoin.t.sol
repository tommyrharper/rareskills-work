// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {NaughtCoin} from "../src/NaughtCoin.sol";

contract NaughtCoinTest is Test {
    NaughtCoin public naughtCoin;

    function setUp() public {
        naughtCoin = new NaughtCoin(address(this));
    }

    function testSpendTokens() public {
        address buddy = address(0x1);
        naughtCoin.approve(buddy, type(uint256).max);

        uint256 allTokens = naughtCoin.totalSupply();

        vm.prank(buddy);
        naughtCoin.transferFrom(address(this), buddy, allTokens);

        assertEq(naughtCoin.balanceOf(address(this)), 0);
    }
}
