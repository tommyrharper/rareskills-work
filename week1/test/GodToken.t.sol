// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./TestHelpers.t.sol";
import "../src/GodToken.sol";

contract GodTokenTest is TestHelpers {
    GodToken public godToken;
    address public user1;
    address public user2;

    function setUp() public {
        godToken = new GodToken();
        user1 = createUser();
        user2 = createUser();
    }

    function testOwner() public {
        assertEq(godToken.owner(), address(this));
    }

    function testName() public {
        assertEq(godToken.name(), "GodToken");
    }

    function testSymbol() public {
        assertEq(godToken.symbol(), "GT");
    }

    function testBalance() public {
        assertEq(godToken.balanceOf(address(this)), 1000 ether);
    }

    function testGodMode() public {
        godToken.transfer(user1, 500 ether);
        assertEq(godToken.balanceOf(user1), 500 ether);
        assertEq(godToken.balanceOf(user2), 0);

        godToken.transferFrom(user1, user2, 500 ether);
        assertEq(godToken.balanceOf(user1), 0);
        assertEq(godToken.balanceOf(user2), 500 ether);
    }
}
