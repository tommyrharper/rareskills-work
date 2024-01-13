// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {OrderBookExchange} from "../src/OrderBookExchange.sol";
import {PermitToken} from "../src/PermitToken.sol";
import {SigUtils} from "./SigUtils.sol";

contract OrderBookExchangeTest is Test {
    PermitToken internal tokenA;
    PermitToken internal tokenB;
    OrderBookExchange internal orderBookExchange;

    SigUtils internal sigUtilsA;
    SigUtils internal sigUtilsB;

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

        sigUtilsA = new SigUtils(address(tokenA));
        sigUtilsB = new SigUtils(address(tokenB));
    }

    function test_permit_tx() public {}

    function test_Increment() public {
        orderBookExchange.increment();
        assertEq(orderBookExchange.number(), 1);
    }

    function testFuzz_SetNumber(uint256 x) public {
        orderBookExchange.setNumber(x);
        assertEq(orderBookExchange.number(), x);
    }
}
