// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./TestHelpers.t.sol";
import "../src/BondingToken.sol";

contract BondingTokenTest is TestHelpers {
    BondingToken public bondingToken;
    address public user1;
    address public user2;

    function setUp() public {
        bondingToken = new BondingToken();
        user1 = createAndDealUser();
        user2 = createAndDealUser();
    }

    function testName() public {
        assertEq(bondingToken.name(), "BondingToken");
    }

    function testSymbol() public {
        assertEq(bondingToken.symbol(), "BT");
    }

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

        uint256 newReserveBalance = purchaseAmount;
        uint256 newSupply = sqrt(newReserveBalance * 2);

        assertEq(bondingToken.balanceOf(address(this)), newSupply);
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

    // function test_Second_Purchase() public {
    //     bondingToken.purchase{value: 1000}();

    //     uint256 totalSupply = bondingToken.totalSupply();
    //     uint256 newReserves = bondingToken.reserveBalance() + 1000;

    //     uint256 newSupply = sqrt(newReserves * 2);
    //     uint256 supplyChange = newSupply - totalSupply;

    //     vm.prank(user1);
    //     bondingToken.purchase{value: 1000}();
    //     assertEq(bondingToken.balanceOf(user1), supplyChange);
    // }
}
