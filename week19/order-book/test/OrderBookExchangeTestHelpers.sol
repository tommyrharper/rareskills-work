// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {OrderBookExchange, Permit} from "../src/OrderBookExchange.sol";
import {PermitToken} from "../src/PermitToken.sol";
import {SigUtils} from "./SigUtils.sol";

contract OrderBookExchangeTestHelpers is Test {
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

        sigUtils = new SigUtils();
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

    function getTokenAPermit(
        uint256 _value
    )
        internal
        view
        returns (Permit memory permit, uint8 v, bytes32 r, bytes32 s)
    {
        return sigUtils.getSignedPermit(tokenA, user1PrivateKey, user2, _value);
    }

    function getTokenBPermit(
        uint256 _value
    )
        internal
        view
        returns (Permit memory permit, uint8 v, bytes32 r, bytes32 s)
    {
        return sigUtils.getSignedPermit(tokenB, user2PrivateKey, user1, _value);
    }
}
