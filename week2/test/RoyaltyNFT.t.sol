// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/RoyaltyNFT.sol";

contract RoyaltyNFTTest is Test {
    RoyaltyNFT public royalty;

    function setUp() public {
        royalty = new RoyaltyNFT();
    }

    function test_Follows_ERC2918() public {
        assertTrue(royalty.supportsInterface(0x2a55205a));
    }

    function test_Follows_ERC165() public {
        assertTrue(royalty.supportsInterface(0x01ffc9a7));
    }
}
