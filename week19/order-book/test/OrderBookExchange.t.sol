// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {OrderBookExchange, Order, SignedOrderAndPermit, OrderWithSig, PermitWithSig} from "../src/OrderBookExchange.sol";
import {PermitToken, Permit} from "../src/PermitToken.sol";
import {SigUtils} from "./SigUtils.sol";
import {OrderBookExchangeTestHelpers} from "./OrderBookExchangeTestHelpers.sol";

contract OrderBookExchangeTest is OrderBookExchangeTestHelpers {
    function test_match_order() public {
        PermitWithSig memory permitWithSigA = getTokenAPermitWithSig(100 ether);
        PermitWithSig memory permitWithSigB = getTokenBPermitWithSig(5 ether);
        OrderWithSig memory orderWithSigA = getTokenAOrderWithSig(
            100 ether,
            50 ether
        );
        OrderWithSig memory orderWithSigB = getTokenBOrderWithSig(
            5 ether,
            10 ether
        );

        SignedOrderAndPermit memory orderA = SignedOrderAndPermit(
            orderWithSigA,
            permitWithSigA
        );

        SignedOrderAndPermit memory orderB = SignedOrderAndPermit(
            orderWithSigB,
            permitWithSigB
        );

        orderBookExchange.matchOrders(orderA, orderB);
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
