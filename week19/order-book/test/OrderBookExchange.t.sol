// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {OrderBookExchange} from "../src/OrderBookExchange.sol";
import {PermitToken} from "../src/PermitToken.sol";
import {SigUtils, Permit} from "./SigUtils.sol";

contract OrderBookExchangeTest is Test {
    PermitToken internal tokenA;
    PermitToken internal tokenB;
    OrderBookExchange internal orderBookExchange;

    SigUtils internal sigUtils;

    uint256 internal user1PrivateKey;
    uint256 internal user2PrivateKey;
    address internal user1;
    address internal user2;

    struct PermitSig {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    function setUp() public {
        user1PrivateKey = 0xA11CE;
        user1 = vm.addr(user1PrivateKey);
        user2PrivateKey = 0xFACADE;
        user2 = vm.addr(user2PrivateKey);

        tokenA = new PermitToken("TokenA", "A", user1);
        tokenB = new PermitToken("TokenB", "B", user2);
        orderBookExchange = new OrderBookExchange();
        orderBookExchange.setNumber(0);

        sigUtils = new SigUtils();
    }

    function test_permit_tokenA() public {
        (Permit memory permit, uint8 v, bytes32 r, bytes32 s) = sigUtils
            .getSignedPermit(tokenA, user1PrivateKey, user2, 1 ether);

        vm.prank(user2);
        tokenA.permit(
            permit.owner,
            permit.spender,
            permit.value,
            permit.deadline,
            v,
            r,
            s
        );

        assertEq(tokenA.balanceOf(user2), 0);

        vm.prank(user2);
        tokenA.transferFrom(user1, user2, 1 ether);

        assertEq(tokenA.balanceOf(user2), 1 ether);
    }

    function test_permit_tokenB() public {
        (Permit memory permit, uint8 v, bytes32 r, bytes32 s) = sigUtils
            .getSignedPermit(tokenB, user2PrivateKey, user1, 1 ether);

        vm.prank(user1);
        tokenB.permit(
            permit.owner,
            permit.spender,
            permit.value,
            permit.deadline,
            v,
            r,
            s
        );

        assertEq(tokenB.balanceOf(user1), 0);

        vm.prank(user1);
        tokenB.transferFrom(user2, user1, 1 ether);

        assertEq(tokenB.balanceOf(user1), 1 ether);
    }

    function test_Increment() public {
        orderBookExchange.increment();
        assertEq(orderBookExchange.number(), 1);
    }

    function testFuzz_SetNumber(uint256 x) public {
        orderBookExchange.setNumber(x);
        assertEq(orderBookExchange.number(), x);
    }
}
