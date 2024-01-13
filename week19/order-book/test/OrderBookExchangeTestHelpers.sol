// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {OrderBookExchange, Order} from "../src/OrderBookExchange.sol";
import {PermitToken, Permit} from "../src/PermitToken.sol";
import {SigUtils} from "./SigUtils.sol";
import {OrderBookSigUtils} from "./OrderBookSigUtils.sol";

contract OrderBookExchangeTestHelpers is Test {
    PermitToken internal tokenA;
    PermitToken internal tokenB;
    OrderBookExchange internal orderBookExchange;

    SigUtils internal sigUtils;
    OrderBookSigUtils internal orderBookSigUtils;

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
        orderBookExchange = new OrderBookExchange(tokenA, tokenB);

        sigUtils = new SigUtils();
        orderBookSigUtils = new OrderBookSigUtils(orderBookExchange);
    }

    function getTokenAOrder(
        uint256 sellAmount,
        uint256 buyAmount
    )
        internal
        view
        returns (Order memory order, uint8 v, bytes32 r, bytes32 s)
    {
        (order, v, r, s) = orderBookSigUtils.getSignedOrder(
            address(tokenA),
            address(tokenB),
            sellAmount,
            buyAmount,
            user1PrivateKey
        );
    }

    function getTokenBOrder(
        uint256 sellAmount,
        uint256 buyAmount
    )
        internal
        view
        returns (Order memory order, uint8 v, bytes32 r, bytes32 s)
    {
        (order, v, r, s) = orderBookSigUtils.getSignedOrder(
            address(tokenB),
            address(tokenA),
            sellAmount,
            buyAmount,
            user2PrivateKey
        );
    }

    function checkOrderIsValid(
        Order memory order,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        if (order.owner == user1) {
            orderBookExchange.checkOrderIsValid(order, v, r, s);
        } else {
            orderBookExchange.checkOrderIsValid(order, v, r, s);
        }
    }

    function getTokenAPermit(
        uint256 _value
    )
        internal
        view
        returns (Permit memory permit, uint8 v, bytes32 r, bytes32 s)
    {
        return
            sigUtils.getSignedPermit(
                tokenA,
                user1PrivateKey,
                address(orderBookExchange),
                _value
            );
    }

    function getTokenBPermit(
        uint256 _value
    )
        internal
        view
        returns (Permit memory permit, uint8 v, bytes32 r, bytes32 s)
    {
        return
            sigUtils.getSignedPermit(
                tokenB,
                user2PrivateKey,
                address(orderBookExchange),
                _value
            );
    }

    function executePermit(
        Permit memory permit,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        if (permit.owner == user1) {
            tokenA.permit(
                permit.owner,
                permit.spender,
                permit.value,
                permit.deadline,
                v,
                r,
                s
            );
        } else {
            tokenB.permit(
                permit.owner,
                permit.spender,
                permit.value,
                permit.deadline,
                v,
                r,
                s
            );
        }
    }
}
