// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/SanctionToken.sol";

contract SanctionTokenTest is Test {
    SanctionToken public sactionToken;

    function setUp() public {
        sactionToken = new SanctionToken();
        sactionToken.setNumber(0);
    }

    function testIncrement() public {
        sactionToken.increment();
        assertEq(sactionToken.number(), 1);
    }

    function testSetNumber(uint256 x) public {
        sactionToken.setNumber(x);
        assertEq(sactionToken.number(), x);
    }
}
