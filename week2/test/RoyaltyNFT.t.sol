// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/RoyaltyNFT.sol";

contract RoyaltyNFTTest is Test {
    RoyaltyNFT public royalty;

    function setUp() public {
        royalty = new RoyaltyNFT(bytes32(""));
    }

    function test_Ownership() public {
        assertEq(royalty.owner(), address(this));
    }

    function test_Follows_ERC2918() public {
        assertTrue(royalty.supportsInterface(0x2a55205a));
    }

    function test_Follows_ERC165() public {
        assertTrue(royalty.supportsInterface(0x01ffc9a7));
    }

    function test_Correct_Royalty_Info_Set() public {
        for (uint256 i = 0; i <= 20; i++) {
            (address recipient, uint256 value) = royalty.royaltyInfo(i, 1000);
            assertEq(recipient, address(this));
            assertEq(value, 25);
        }
    }
}
