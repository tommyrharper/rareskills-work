// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/SwapPair.sol";
import "../src/Factory.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract SwapPairTest is Test {
    Factory public factory;
    SwapPair public swapPair;
    IERC20 public tokenA;
    IERC20 public tokenB;

    function setUp() public {
        tokenA = new ERC20("TokenA", "TA");
        tokenB = new ERC20("TokenB", "TB");
        factory = new Factory(address(this));
        address pair = factory.createPair(address(tokenA), address(tokenB));
        swapPair = SwapPair(pair);
    }

    function test_Mint() public {
        // swapPair.mint(address(this));
    }
}
