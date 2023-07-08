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

    function testBalance() public {
        assertEq(sactionToken.balanceOf(address(this)), 1000 ether);
    }

    function testBanUpdatesMapping() public {
        sactionToken.ban(user1, true);
        assertEq(sactionToken.blackList(user1), true);
    }

    function testUnBanUpdatesMapping() public {
        sactionToken.ban(user1, true);
        assertEq(sactionToken.blackList(user1), true);

        sactionToken.ban(user1, false);
        assertEq(sactionToken.blackList(user1), false);
    }

    function testBanIsOnlyOwner() public {
        vm.prank(address(user2));
        vm.expectRevert("Ownable: caller is not the owner");
        sactionToken.ban(user1, true);
    }

    function testBanBlocksTransfersToBannedAddresses() public {
        sactionToken.ban(user1, true);
        assertEq(sactionToken.blackList(user1), true);

        vm.expectRevert(
            abi.encodeWithSelector(
                SanctionToken.BannedToAddress.selector,
                user1
            )
        );
        sactionToken.transfer(user1, 100);
    }

    function testBanBlocksTransfersFromBannedAddresses() public {
        sactionToken.ban(address(this), true);
        assertEq(sactionToken.blackList(address(this)), true);

        vm.expectRevert(
            abi.encodeWithSelector(
                SanctionToken.BannedFromAddress.selector,
                address(this)
            )
        );
        sactionToken.transfer(user1, 100);
    }
}
