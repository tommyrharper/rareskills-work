// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Factory.sol";

contract FactoryTest is Test {
    Factory public factory;

    function setUp() public {
        factory = new Factory(address(this));
    }

    function testFactory() public {
        address tokenA = address(0x1);
        address tokenB = address(0x2);
        address pair = factory.createPair(tokenA, tokenB);
        assertEq(factory.allPairsLength(), 1);
        assertEq(factory.allPairs(0), pair);
        assertEq(factory.getPair(tokenA, tokenB), pair);
        assertEq(factory.getPair(tokenB, tokenA), pair);
    }
}
