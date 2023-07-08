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
        user1 = createUser();
        user2 = createUser();
    }

    function testName() public {
        assertEq(bondingToken.name(), "BondingToken");
    }

    function testSymbol() public {
        assertEq(bondingToken.symbol(), "BT");
    }

    function test_buyBondingToken_First_Purchase_0() public {
        vm.expectRevert(BondingToken.MustPayGreaterThanZero.selector);
        bondingToken.buyBondingToken{value: 0}();
    }

    function test_buyBondingToken_First_Purchase_1() public {
        bondingToken.buyBondingToken{value: 1}();
        assertEq(bondingToken.balanceOf(address(this)), 1);
    }

    function test_buyBondingToken_First_Purchase_3() public {
        bondingToken.buyBondingToken{value: 3}();
        assertEq(bondingToken.balanceOf(address(this)), 2);
    }

    function test_buyBondingToken_First_Purchase_8() public {
        bondingToken.buyBondingToken{value: 8}();
        assertEq(bondingToken.balanceOf(address(this)), 4);
    }

    function test_buyBondingToken_First_Purchase_1000() public {
        bondingToken.buyBondingToken{value: 1000}();
        assertEq(bondingToken.balanceOf(address(this)), 44);
    }

    function test_buyBondingToken_First_Purchase_Fuzz(
        uint64 purchaseAmount
    ) public {
        vm.assume(purchaseAmount > 0);

        bondingToken.buyBondingToken{value: purchaseAmount}();

        uint256 newReserveBalance = purchaseAmount;
        uint256 newSupply = sqrt(newReserveBalance * 2);

        assertEq(bondingToken.balanceOf(address(this)), newSupply);
    }
}
