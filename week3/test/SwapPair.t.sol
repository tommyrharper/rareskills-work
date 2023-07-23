// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/SwapPair.sol";
import "../src/Factory.sol";
import "./MintableERC20.t.sol";

contract SwapPairTest is Test {
    Factory public factory;
    SwapPair public swapPair;
    MintableERC20 public tokenA;
    MintableERC20 public tokenB;

    function setUp() public {
        tokenA = new MintableERC20("TokenA", "TA");
        tokenB = new MintableERC20("TokenB", "TB");
        factory = new Factory(address(this));
        address pair = factory.createPair(address(tokenA), address(tokenB));
        swapPair = SwapPair(pair);
    }

    function test_Equal_First_Mint() public {
        tokenA.mint(address(swapPair), 10_000);
        tokenB.mint(address(swapPair), 10_000);
        swapPair.mint(address(this));
        assertEq(swapPair.balanceOf(address(this)), 9_000);
    }
}
