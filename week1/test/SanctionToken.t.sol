// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/SanctionToken.sol";

contract SanctionTokenTest is Test {
    SanctionToken public sactionToken;

    function setUp() public {
        sactionToken = new SanctionToken();
    }

    function testOwner() public {
        assertEq(sactionToken.owner(), address(this));
    }

    function testName() public {
        assertEq(sactionToken.name(), "SanctionToken");
    }

    function testSymbol() public {
        assertEq(sactionToken.symbol(), "ST");
    }

    function testBan() public {
        sactionToken.ban(address(0x1), true);
        assertEq(sactionToken.blackList(address(0x1)), true);
    }

}
