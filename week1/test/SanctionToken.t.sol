// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./TestHelpers.t.sol";
import "../src/SanctionToken.sol";

contract SanctionTokenTest is TestHelpers {
    SanctionToken public sactionToken;
    address public user1;
    address public user2;

    function setUp() public {
        sactionToken = new SanctionToken();
        user1 = createUser();
        user2 = createUser();
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

    function testBanUpdatesMapping() public {
        sactionToken.ban(address(user1), true);
        assertEq(sactionToken.blackList(address(user1)), true);
    }

    function testUnBanUpdatesMapping() public {
        sactionToken.ban(address(user1), true);
        assertEq(sactionToken.blackList(address(user1)), true);

        sactionToken.ban(address(user1), false);
        assertEq(sactionToken.blackList(address(user1)), false);
    }

    function testBanIsOnlyOwner() public {
        vm.prank(address(user2));
        vm.expectRevert("Ownable: caller is not the owner");
        sactionToken.ban(address(user1), true);
    }

    function testBanBlocksTransfers() public {

    }

}
