// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./TestHelpers.t.sol";
import "../src/BondingToken.sol";

contract BondingTokenTest is TestHelpers {
    /*//////////////////////////////////////////////////////////////
                                 STATE
    //////////////////////////////////////////////////////////////*/

    BondingToken public bondingToken;
    address public user1;
    address public user2;

    /*//////////////////////////////////////////////////////////////
                                 SETUP
    //////////////////////////////////////////////////////////////*/

    function setUp() public {
        bondingToken = new BondingToken();
        user1 = createAndDealUser();
        user2 = createAndDealUser();
    }

    /*//////////////////////////////////////////////////////////////
                              ERC20 TESTS
    //////////////////////////////////////////////////////////////*/

    function testName() public {
        assertEq(bondingToken.name(), "BondingToken");
    }

    function testSymbol() public {
        assertEq(bondingToken.symbol(), "BT");
    }

    /*//////////////////////////////////////////////////////////////
                             PURCHASE TESTS
    //////////////////////////////////////////////////////////////*/

    function test_First_Purchase_0() public {
        vm.expectRevert(BondingToken.MustPayGreaterThanZero.selector);
        bondingToken.purchase{value: 0}();
    }

    function test_First_Purchase_1() public {
        bondingToken.purchase{value: 1}();
        assertEq(bondingToken.balanceOf(address(this)), 1);
    }

    function test_First_Purchase_3() public {
        bondingToken.purchase{value: 3}();
        assertEq(bondingToken.balanceOf(address(this)), 2);
    }

    function test_First_Purchase_8() public {
        bondingToken.purchase{value: 8}();
        assertEq(bondingToken.balanceOf(address(this)), 4);
    }

    function test_First_Purchase_1000() public {
        bondingToken.purchase{value: 1000}();
        assertEq(bondingToken.balanceOf(address(this)), 44);
    }

    function test_First_Purchase_Fuzz(uint64 purchaseAmount) public {
        vm.assume(purchaseAmount > 0);
        bondingToken.purchase{value: purchaseAmount}();

        assertEq(
            bondingToken.balanceOf(address(this)),
            calculateSupplyChange(0, purchaseAmount)
        );
    }

    function test_Second_Purchase() public {
        bondingToken.purchase{value: 1000}();

        // firstPurchaseReserves = 1000
        // firstPurchaseSupply = sqrt(1000 * 2) = 44
        // newReservers = 2000
        // newSupply = sqrt(2000 * 2) = 63
        // change in supply = 63 - 44 = 19

        vm.prank(user1);
        bondingToken.purchase{value: 1000}();
        assertEq(bondingToken.balanceOf(user1), 19);
    }

    function test_Second_Purchase_Fuzz(
        uint64 firstPurchase,
        uint64 secondPurchase
    ) public {
        vm.assume(firstPurchase > 0);
        vm.assume(secondPurchase > 0);

        bondingToken.purchase{value: firstPurchase}();
        assertEq(
            bondingToken.balanceOf(address(this)),
            calculateSupplyChange(0, firstPurchase)
        );

        vm.prank(user1);
        bondingToken.purchase{value: secondPurchase}();
        assertEq(
            bondingToken.balanceOf(user1),
            calculateSupplyChange(firstPurchase, secondPurchase)
        );
    }

    /*//////////////////////////////////////////////////////////////
                               SELL TESTS
    //////////////////////////////////////////////////////////////*/

    function test_Sell_All_Tokens() public {
        uint256 startingEtherBalance = user1.balance;
        vm.prank(user1);
        bondingToken.purchase{value: 1000}();

        uint256 tokenBalance = bondingToken.balanceOf(user1);
        vm.prank(user1);
        bondingToken.sell(tokenBalance);
        assertEq(bondingToken.balanceOf(user1), 0);

        assertEq(user1.balance, startingEtherBalance);
    }

    function test_Sell_Tokens_Transfer_Fails() public {
        bondingToken.purchase{value: 1000}();

        uint256 tokenBalance = bondingToken.balanceOf(address(this));
        vm.expectRevert(BondingToken.PayoutFailed.selector);
        bondingToken.sell(tokenBalance);
    }

    /*//////////////////////////////////////////////////////////////
                                HELPERS
    //////////////////////////////////////////////////////////////*/

    function calculateSupplyChange(
        uint256 initialReserves,
        uint256 addedReserves
    ) internal view returns (uint256) {
        uint256 newReserves = initialReserves + addedReserves;

        uint256 initialSupply = sqrt(initialReserves * 2);
        uint256 newSupply = sqrt(newReserves * 2);

        return newSupply - initialSupply;
    }
}
