// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {OrderBookExchange} from "../src/OrderBookExchange.sol";

contract OrderBookExchangeTest is Test {
    OrderBookExchange public orderBookExchange;

    function setUp() public {
        orderBookExchange = new OrderBookExchange();
        orderBookExchange.setNumber(0);
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
