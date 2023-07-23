// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/SwapPair.sol";
import "../src/Factory.sol";
import "./MintableERC20.t.sol";
import "lib/openzeppelin-contracts/contracts/utils/math/Math.sol";

contract SwapPairTest is Test {
    /*//////////////////////////////////////////////////////////////
                                 STATE
    //////////////////////////////////////////////////////////////*/

    Factory public factory;
    SwapPair public swapPair;
    MintableERC20 public tokenA;
    MintableERC20 public tokenB;

    /*//////////////////////////////////////////////////////////////
                                 SETUP
    //////////////////////////////////////////////////////////////*/

    function setUp() public {
        tokenA = new MintableERC20("TokenA", "TA");
        tokenB = new MintableERC20("TokenB", "TB");
        factory = new Factory(address(this));
        address pair = factory.createPair(address(tokenA), address(tokenB));
        swapPair = SwapPair(pair);
    }

    /*//////////////////////////////////////////////////////////////
                               FIRST MINT
    //////////////////////////////////////////////////////////////*/

    function test_Equal_First_Mint() public {
        sendAndMint(10_000);
        assertEq(swapPair.balanceOf(address(this)), 9_000);
    }

    function test_Equal_First_Mint_Fuzz(uint64 amount) public {
        uint256 minLiquidity = swapPair.MINIMUM_LIQUIDITY();
        sendTokensToSwapPair(amount);
        if (amount <= minLiquidity) {
            vm.expectRevert();
            swapPair.mint(address(this));
        } else {
            swapPair.mint(address(this));
            assertEq(swapPair.balanceOf(address(this)), amount - minLiquidity);
        }
    }

    function test_Unequal_First_Mint() public {
        sendAndMint(25_000, 1_000);
        assertEq(swapPair.balanceOf(address(this)), 4_000);
    }

    function test_Unequal_First_Mint_Fuzz(
        uint64 _amountA,
        uint64 _amountB
    ) public {
        uint256 amountA = _amountA;
        uint256 amountB = _amountB;
        uint256 minLiquidity = swapPair.MINIMUM_LIQUIDITY();
        uint256 sqrt = Math.sqrt(amountA * amountB);
        sendTokensToSwapPair(amountA, amountB);
        if (sqrt <= minLiquidity) {
            vm.expectRevert();
            swapPair.mint(address(this));
        } else {
            swapPair.mint(address(this));
            assertEq(swapPair.balanceOf(address(this)), sqrt - minLiquidity);
        }
    }

    /*//////////////////////////////////////////////////////////////
                              SECOND MINT
    //////////////////////////////////////////////////////////////*/

    function test_Equal_Second_Mint() public {
        sendAndMint(10_000);
        assertEq(swapPair.balanceOf(address(this)), 9_000);
        sendAndMint(10_000);
        assertEq(swapPair.balanceOf(address(this)), 19_000);
    }

    function test_Equal_Second_Mint_Fuzz(uint64 _amount) public {
        uint256 amount = _amount;
        sendAndMint(10_000);
        assertEq(swapPair.balanceOf(address(this)), 9_000);
        sendTokensToSwapPair(amount);
        if (amount <= 0) {
            vm.expectRevert("UniswapV2: INSUFFICIENT_LIQUIDITY_MINTED");
            swapPair.mint(address(this));
        } else {
            swapPair.mint(address(this));
            assertEq(swapPair.balanceOf(address(this)), 9_000 + amount);
        }
    }

    /*//////////////////////////////////////////////////////////////
                                  BURN
    //////////////////////////////////////////////////////////////*/

    function test_Burn() public {
        sendAndMint(10_000);
        assertEq(swapPair.balanceOf(address(this)), 9_000);
        swapPair.transfer(address(swapPair), 1_000);
        swapPair.burn(address(this));
        assertEq(swapPair.balanceOf(address(this)), 8_000);
        assertEq(tokenA.balanceOf(address(this)), 1_000);
        assertEq(tokenB.balanceOf(address(this)), 1_000);
    }

    /*//////////////////////////////////////////////////////////////
                                HELPERS
    //////////////////////////////////////////////////////////////*/

    function sendAndMint(uint256 amount) public {
        sendTokensToSwapPair(amount);
        swapPair.mint(address(this));
    }

    function sendAndMint(uint256 tokenAAmount, uint256 tokenBAmount) public {
        sendTokensToSwapPair(tokenAAmount, tokenBAmount);
        swapPair.mint(address(this));
    }

    function sendTokensToSwapPair(uint256 amount) public {
        tokenA.mint(address(swapPair), amount);
        tokenB.mint(address(swapPair), amount);
    }

    function sendTokensToSwapPair(
        uint256 tokenAAmount,
        uint256 tokenBAmount
    ) public {
        tokenA.mint(address(swapPair), tokenAAmount);
        tokenB.mint(address(swapPair), tokenBAmount);
    }
}
