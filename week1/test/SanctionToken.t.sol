// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "./TestHelpers.t.sol";
import "../src/SanctionToken.sol";

contract SanctionTokenTest is TestHelpers {
    SanctionToken public sanctionToken;
    address public user1;
    address public user2;

    function setUp() public {
        sanctionToken = new SanctionToken();
        user1 = createUser();
        user2 = createUser();
    }

    function testOwner() public {
        assertEq(sanctionToken.owner(), address(this));
    }

    function testName() public {
        assertEq(sanctionToken.name(), "SanctionToken");
    }

    function testSymbol() public {
        assertEq(sanctionToken.symbol(), "ST");
    }

    function testBalance() public {
        assertEq(sanctionToken.balanceOf(address(this)), 1000 ether);
    }

    function testBanUpdatesMapping() public {
        sanctionToken.ban(user1, true);
        assertEq(sanctionToken.blackList(user1), true);
    }

    function testUnBanUpdatesMapping() public {
        sanctionToken.ban(user1, true);
        assertEq(sanctionToken.blackList(user1), true);

        sanctionToken.ban(user1, false);
        assertEq(sanctionToken.blackList(user1), false);
    }

    function testBanIsOnlyOwner() public {
        vm.prank(address(user2));
        vm.expectRevert("Ownable: caller is not the owner");
        sanctionToken.ban(user1, true);
    }

    function testBanBlocksTransfersToBannedAddresses() public {
        sanctionToken.ban(user1, true);
        assertEq(sanctionToken.blackList(user1), true);

        vm.expectRevert(
            abi.encodeWithSelector(
                SanctionToken.BannedToAddress.selector,
                user1
            )
        );
        sanctionToken.transfer(user1, 100);
    }

    function testBanBlocksTransfersFromToBannedAddresses() public {
        sanctionToken.approve(address(this), 1000 ether);

        sanctionToken.ban(user1, true);
        assertEq(sanctionToken.blackList(user1), true);

        vm.expectRevert(
            abi.encodeWithSelector(
                SanctionToken.BannedToAddress.selector,
                user1
            )
        );
        sanctionToken.transferFrom(address(this), user1, 100);
    }

    function testBanBlocksTransfersFromBannedAddresses() public {
        sanctionToken.ban(address(this), true);
        assertEq(sanctionToken.blackList(address(this)), true);

        vm.expectRevert(
            abi.encodeWithSelector(
                SanctionToken.BannedFromAddress.selector,
                address(this)
            )
        );
        sanctionToken.transfer(user1, 100);
    }

    function testBanBlocksTransfersFromFromBannedAddresses() public {
        sanctionToken.approve(address(this), 1000 ether);

        sanctionToken.ban(address(this), true);
        assertEq(sanctionToken.blackList(address(this)), true);

        vm.expectRevert(
            abi.encodeWithSelector(
                SanctionToken.BannedFromAddress.selector,
                address(this)
            )
        );
        sanctionToken.transferFrom(address(this), user1, 100);
    }
}
