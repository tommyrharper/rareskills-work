// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {OrderBookExchange} from "../src/OrderBookExchange.sol";
import {PermitToken, Permit} from "../src/PermitToken.sol";
import {SigUtils} from "./SigUtils.sol";
import {OrderBookExchangeTestHelpers} from "./OrderBookExchangeTestHelpers.sol";

contract OrderBookExchangeTest is OrderBookExchangeTestHelpers {
    function test_permit_tokenA() public {
        (Permit memory permit, uint8 v, bytes32 r, bytes32 s) = getTokenAPermit(
            1 ether
        );

        executePermit(permit, v, r, s);

        assertEq(tokenA.balanceOf(user2), 0);

        vm.prank(user2);
        tokenA.transferFrom(user1, user2, 1 ether);

        assertEq(tokenA.balanceOf(user2), 1 ether);
    }

    function test_permit_tokenB() public {
        (Permit memory permit, uint8 v, bytes32 r, bytes32 s) = getTokenBPermit(
            1 ether
        );

        executePermit(permit, v, r, s);

        assertEq(tokenB.balanceOf(user1), 0);

        vm.prank(user1);
        tokenB.transferFrom(user2, user1, 1 ether);

        assertEq(tokenB.balanceOf(user1), 1 ether);
    }
}
