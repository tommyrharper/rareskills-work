// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {OrderBookExchange, Order} from "../src/OrderBookExchange.sol";
import {PermitToken, Permit} from "../src/PermitToken.sol";
import {SigUtils} from "./SigUtils.sol";
import {OrderBookExchangeTestHelpers} from "./OrderBookExchangeTestHelpers.sol";

contract OrderBookExchangeTest is OrderBookExchangeTestHelpers {
    function test_match_order() public {
        // (Permit memory permit, uint8 v, bytes32 r, bytes32 s) = getTokenAPermit(
        //     1 ether
        // );
    }

    function test_permit_tokenA() public {
        (Permit memory permit, uint8 v, bytes32 r, bytes32 s) = getTokenAPermit(
            1 ether
        );

        executePermit(permit, v, r, s);

        assertEq(tokenA.balanceOf(address(orderBookExchange)), 0);

        vm.prank(address(orderBookExchange));
        tokenA.transferFrom(user1, address(orderBookExchange), 1 ether);

        assertEq(tokenA.balanceOf(address(orderBookExchange)), 1 ether);
    }

    function test_permit_tokenB() public {
        (Permit memory permit, uint8 v, bytes32 r, bytes32 s) = getTokenBPermit(
            1 ether
        );

        executePermit(permit, v, r, s);

        assertEq(tokenB.balanceOf(address(orderBookExchange)), 0);

        vm.prank(address(orderBookExchange));
        tokenB.transferFrom(user2, address(orderBookExchange), 1 ether);

        assertEq(tokenB.balanceOf(address(orderBookExchange)), 1 ether);
    }

    function test_order_user1() public {
        (Order memory order, uint8 v, bytes32 r, bytes32 s) = getTokenAOrder(
            1 ether,
            1 ether
        );

        checkOrderIsValid(order, v, r, s);
    }

    function test_order_user2() public {
        (Order memory order, uint8 v, bytes32 r, bytes32 s) = getTokenBOrder(
            1 ether,
            1 ether
        );

        checkOrderIsValid(order, v, r, s);
    }
}
