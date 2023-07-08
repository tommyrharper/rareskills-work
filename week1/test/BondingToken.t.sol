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

    function test_buyBondingToken_First_Purchase() public {
        bondingToken.buyBondingToken{value: 8 ether}();
        assertEq(bondingToken.balanceOf(address(this)), 4 ether);
    }
}
