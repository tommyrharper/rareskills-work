// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "./TestHelpers.t.sol";
import "../src/BondingTokenERC777.sol";

contract BondingTokenERC777Test is TestHelpers {
    /*//////////////////////////////////////////////////////////////
                                 STATE
    //////////////////////////////////////////////////////////////*/

    BondingTokenERC777 public bondingToken;
    address public user1;
    address public user2;

    /*//////////////////////////////////////////////////////////////
                                 SETUP
    //////////////////////////////////////////////////////////////*/

    function setUp() public {
        bondingToken = new BondingTokenERC777();
        user1 = createAndDealUser();
        user2 = createAndDealUser();
    }

    /*//////////////////////////////////////////////////////////////
                              ERC20 TESTS
    //////////////////////////////////////////////////////////////*/

    function testName() public {
        assertEq(bondingToken.name(), "BondingTokenERC777");
    }

    function testSymbol() public {
        assertEq(bondingToken.symbol(), "BT");
    }

    /*//////////////////////////////////////////////////////////////
                             PURCHASE TESTS
    //////////////////////////////////////////////////////////////*/

    function test_First_Purchase_0() public {
        vm.expectRevert(BondingTokenERC777.MustPayGreaterThanZero.selector);
        bondingToken.purchase{value: 0}(address(this), 0);
    }

    function test_First_Purchase_1() public {
        bondingToken.purchase{value: 1}(address(this), 0);
        assertEq(bondingToken.balanceOf(address(this)), 1);
    }

    function test_Purchase_1_Different_To_Address() public {
        bondingToken.purchase{value: 1}(user1, 0);
        assertEq(bondingToken.balanceOf(user1), 1);
    }

    function test_First_Purchase_3() public {
        bondingToken.purchase{value: 3}(address(this), 0);
        assertEq(bondingToken.balanceOf(address(this)), 2);
    }

    function test_First_Purchase_8() public {
        bondingToken.purchase{value: 8}(address(this), 0);
        assertEq(bondingToken.balanceOf(address(this)), 4);
    }

    function test_First_Purchase_1000() public {
        bondingToken.purchase{value: 1000}(address(this), 0);
        assertEq(bondingToken.balanceOf(address(this)), 44);
    }

    function test_First_Purchase_Fuzz(uint64 purchaseAmount) public {
        vm.assume(purchaseAmount > 0);
        bondingToken.purchase{value: purchaseAmount}(address(this), 0);

        assertEq(
            bondingToken.balanceOf(address(this)),
            calculateSupplyChange(0, purchaseAmount)
        );
    }

    function test_Second_Purchase() public {
        bondingToken.purchase{value: 1000}(address(this), 0);

        // firstPurchaseReserves = 1000
        // firstPurchaseSupply = sqrt(1000 * 2) = 44
        // newReservers = 2000
        // newSupply = sqrt(2000 * 2) = 63
        // change in supply = 63 - 44 = 19

        vm.prank(user1);
        bondingToken.purchase{value: 1000}(user1, 44);
        assertEq(bondingToken.balanceOf(user1), 19);
    }

    function test_Second_Purchase_Fuzz(
        uint64 firstPurchase,
        uint64 secondPurchase
    ) public {
        vm.assume(firstPurchase > 0);
        vm.assume(secondPurchase > 0);

        bondingToken.purchase{value: firstPurchase}(address(this), 0);
        uint256 initalMintAmount = calculateSupplyChange(0, firstPurchase);
        assertEq(bondingToken.balanceOf(address(this)), initalMintAmount);

        uint256 secondPurchaseReturn = calculateSupplyChange(
            firstPurchase,
            secondPurchase
        );
        if (secondPurchaseReturn == 0) {
            vm.expectRevert(BondingTokenERC777.PurchaseTooSmall.selector);
        }
        vm.prank(user1);
        bondingToken.purchase{value: secondPurchase}(user1, initalMintAmount);
        assertEq(bondingToken.balanceOf(user1), secondPurchaseReturn);
    }

    /*//////////////////////////////////////////////////////////////
                               SELL TESTS
    //////////////////////////////////////////////////////////////*/

    function test_Cannot_Sell_Zero() public {
        vm.prank(user1);
        bondingToken.purchase{value: 1000}(user1, 0);

        vm.prank(user1);
        vm.expectRevert(BondingTokenERC777.MustSellGreaterThanZero.selector);
        bondingToken.sell(user1, 0, 44);
    }

    function test_Sell_All_Tokens() public {
        uint256 startingEtherBalance = user1.balance;
        vm.prank(user1);
        bondingToken.purchase{value: 1000}(user1, 0);

        uint256 tokenBalance = bondingToken.balanceOf(user1);
        vm.prank(user1);
        bondingToken.sell(user1, tokenBalance, 44);
        assertEq(bondingToken.balanceOf(user1), 0);

        assertEq(user1.balance, startingEtherBalance);
    }

    function test_Sell_And_Send_To_Other_Address() public {
        uint256 startingUser1EtherBalance = user1.balance;
        uint256 startingUser2EtherBalance = user2.balance;
        vm.prank(user1);
        bondingToken.purchase{value: 1000}(user1, 0);

        uint256 tokenBalance = bondingToken.balanceOf(user1);
        vm.prank(user1);
        bondingToken.sell(user2, tokenBalance, 44);
        assertEq(bondingToken.balanceOf(user1), 0);

        assertEq(user1.balance, startingUser1EtherBalance - 1000);
        assertEq(user2.balance, startingUser2EtherBalance + 1000);
    }

    function test_Sell_Partial_Tokens() public {
        vm.prank(user1);
        bondingToken.purchase{value: 1000}(user1, 0);

        uint256 balanceBeforeSelling = user1.balance;
        vm.prank(user1);
        bondingToken.sell(user1, 22, 44);
        assertEq(bondingToken.balanceOf(user1), 22);

        // expected returned eth
        // initial_total_supply = 44
        // final_total_supply = 22
        // new_reserve_balance = (22 ** 2) / 2 = 242
        // change_in_reserves = 1000 - 242 = 758

        assertEq(user1.balance, balanceBeforeSelling + 758);
    }

    function test_Sell_Tokens_Fuzz(
        uint64 purchaseAmount,
        uint64 saleAmount
    ) public {
        vm.assume(purchaseAmount > 0);
        vm.assume(saleAmount > 0);

        bondingToken.purchase{value: purchaseAmount}(address(this), 0);
        uint256 purchasedTokens = calculateSupplyChange(0, purchaseAmount);
        bondingToken.transfer(user1, purchasedTokens);

        uint256 balanceBefore = user1.balance;
        if (saleAmount > purchasedTokens) {
            vm.prank(user1);
            vm.expectRevert(BondingTokenERC777.InsufficientBalance.selector);
            bondingToken.sell(user1, saleAmount, purchasedTokens);
            return;
        } else {
            vm.prank(user1);
            bondingToken.sell(user1, saleAmount, purchasedTokens);
        }

        uint256 expectedPayout = calculatePayout(
            purchasedTokens,
            purchaseAmount,
            saleAmount
        );
        assertEq(user1.balance, balanceBefore + expectedPayout);
    }

    function test_Sell_Tokens_Transfer_Fails() public {
        bondingToken.purchase{value: 1000}(address(this), 0);

        uint256 tokenBalance = bondingToken.balanceOf(address(this));
        vm.expectRevert(BondingTokenERC777.PayoutFailed.selector);
        bondingToken.sell(address(this), tokenBalance, 44);
    }

    /*//////////////////////////////////////////////////////////////
                       SELL VIA TRANSFER AND CALL
    //////////////////////////////////////////////////////////////*/

    // function test_Sell_Via_Transfer_And_Call() public {
    //     uint256 startingEtherBalance = user1.balance;
    //     vm.prank(user1);
    //     bondingToken.purchase{value: 1000}(user1, 0);

    //     uint256 tokenBalance = bondingToken.balanceOf(user1);
    //     vm.prank(user1);
    //     uint256 minExitPrice = 44;
    //     bondingToken.transferAndCall(
    //         address(bondingToken),
    //         tokenBalance,
    //         abi.encodePacked(minExitPrice)
    //     );
    //     assertEq(bondingToken.balanceOf(user1), 0);

    //     assertEq(user1.balance, startingEtherBalance);
    // }

    // function test_Cannot_Sell_Via_Transfer_And_Call_Without_Data() public {
    //     vm.prank(user1);
    //     bondingToken.purchase{value: 1000}(user1, 0);

    //     uint256 tokenBalance = bondingToken.balanceOf(user1);
    //     vm.prank(user1);
    //     vm.expectRevert(BondingTokenERC777.InvalidMinExitPriceData.selector);
    //     bondingToken.transferAndCall(address(bondingToken), tokenBalance);
    // }

    // function test_Cannot_Sell_Via_Transfer_And_Call_With_High_Exit_Price()
    //     public
    // {
    //     vm.prank(user1);
    //     bondingToken.purchase{value: 1000}(user1, 0);

    //     uint256 tokenBalance = bondingToken.balanceOf(user1);
    //     vm.prank(user1);
    //     uint256 minExitPrice = 45;
    //     vm.expectRevert(BondingTokenERC777.MaxSlippageExceeded.selector);
    //     bondingToken.transferAndCall(
    //         address(bondingToken),
    //         tokenBalance,
    //         abi.encodePacked(minExitPrice)
    //     );
    // }

    /*//////////////////////////////////////////////////////////////
                         MAX ENTRY PRICE TESTS
    //////////////////////////////////////////////////////////////*/

    function test_Max_Entry_Price() public {
        bondingToken.purchase{value: 1000}(address(this), 0);

        // mock front runner
        vm.prank(user1);
        bondingToken.purchase{value: 100}(user1, 44);

        // user being frontrun - transaction reverts due to max slippage setting
        vm.expectRevert(BondingTokenERC777.MaxSlippageExceeded.selector);
        bondingToken.purchase{value: 100}(address(this), 44);
    }

    function test_Max_Entry_Price_Fuzz(
        uint64 firstPurchase,
        uint64 secondPurchase,
        uint64 slippageAllowed
    ) public {
        vm.assume(firstPurchase > 0);
        vm.assume(secondPurchase > 0);

        uint256 finalPurchaseReturn = calculateSupplyChange(
            firstPurchase,
            secondPurchase
        );

        vm.assume(finalPurchaseReturn > 0);

        /// front runner
        bondingToken.purchase{value: firstPurchase}(address(this), 0);
        uint256 frontRunnerPriceImpact = calculateSupplyChange(
            0,
            firstPurchase
        );
        assertEq(bondingToken.balanceOf(address(this)), frontRunnerPriceImpact);

        // user being frontrun
        vm.prank(user1);
        if (slippageAllowed < frontRunnerPriceImpact) {
            vm.expectRevert(BondingTokenERC777.MaxSlippageExceeded.selector);
            bondingToken.purchase{value: secondPurchase}(
                user1,
                slippageAllowed
            );
        } else {
            bondingToken.purchase{value: secondPurchase}(
                user1,
                slippageAllowed
            );
            assertEq(bondingToken.balanceOf(user1), finalPurchaseReturn);
        }
    }

    /*//////////////////////////////////////////////////////////////
                          MIN EXIT PRICE TESTS
    //////////////////////////////////////////////////////////////*/

    function test_Min_Exit_Price() public {
        vm.prank(user1);
        bondingToken.purchase{value: 1000}(user1, 0);

        vm.prank(user2);
        bondingToken.purchase{value: 1000}(user2, 44);

        // frontrunner
        vm.prank(user2);
        bondingToken.sell(user2, 19, 63);

        vm.prank(user1);
        vm.expectRevert(BondingTokenERC777.MaxSlippageExceeded.selector);
        bondingToken.sell(user1, 44, 63);
    }

    function test_Min_Exit_Price_Fuzz(
        uint64 user1Purchase,
        uint64 user2Purchase,
        uint64 slippageAllowed
    ) public {
        vm.assume(user1Purchase > 0);
        vm.assume(user2Purchase > 0);

        uint256 user1MintedTokens = calculateSupplyChange(0, user1Purchase);
        uint256 user2MintedTokens = calculateSupplyChange(
            user1Purchase,
            user2Purchase
        );

        vm.assume(user2MintedTokens > 0);

        vm.prank(user1);
        bondingToken.purchase{value: user1Purchase}(user1, 0);

        vm.prank(user2);
        bondingToken.purchase{value: user2Purchase}(user2, user1MintedTokens);
        uint256 newTotalSupply = bondingToken.totalSupply();

        // frontrunner
        vm.prank(user2);
        bondingToken.sell(user2, user2MintedTokens, newTotalSupply);

        uint256 minExitPrice = slippageAllowed > newTotalSupply
            ? 0
            : newTotalSupply - slippageAllowed;

        if (minExitPrice > bondingToken.totalSupply()) {
            vm.expectRevert(BondingTokenERC777.MaxSlippageExceeded.selector);
        }
        vm.prank(user1);
        bondingToken.sell(user1, user1MintedTokens, minExitPrice);
    }

    /*//////////////////////////////////////////////////////////////
                         TRADE TOO SMALL TESTS
    //////////////////////////////////////////////////////////////*/

    function test_Purchase_Too_Small() public {
        bondingToken.purchase{value: 1000 ether}(address(this), 0);
        uint256 supply = bondingToken.totalSupply();

        vm.expectRevert(BondingTokenERC777.PurchaseTooSmall.selector);
        bondingToken.purchase{value: 100}(address(this), supply);
    }

    /*//////////////////////////////////////////////////////////////
                                HELPERS
    //////////////////////////////////////////////////////////////*/

    function calculateSupplyChange(
        uint256 initialReserves,
        uint256 addedReserves
    ) internal pure returns (uint256) {
        uint256 newReserves = initialReserves + addedReserves;

        uint256 initialSupply = sqrt(initialReserves * 2);
        uint256 newSupply = sqrt(newReserves * 2);

        return newSupply - initialSupply;
    }

    function calculatePayout(
        uint256 initialTotalSupply,
        uint256 oldReserves,
        uint256 amountBurnt
    ) internal pure returns (uint256) {
        uint256 newTotalSupply = initialTotalSupply - amountBurnt;
        uint256 newReserves = (newTotalSupply ** 2) / 2;
        return oldReserves - newReserves;
    }
}
