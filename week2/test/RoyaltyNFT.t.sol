// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {TestHelpers} from "./TestHelpers.t.sol";
import "../src/RoyaltyNFT.sol";
import "murky/Merkle.sol";

contract RoyaltyNFTTest is TestHelpers {
    RoyaltyNFT public royalty;
    Merkle public tree;

    address internal user1;
    address internal user2;
    address internal user3;
    address internal user4;
    bytes32[] internal leaves = new bytes32[](4);

    function setUp() public {
        user1 = createAndDealUser();
        user2 = createAndDealUser();
        user3 = createAndDealUser();
        user4 = createAndDealUser();

        tree = new Merkle();
        leaves[0] = keccak256(bytes(abi.encode(user1, 0)));
        leaves[1] = keccak256(bytes(abi.encode(user2, 1)));
        leaves[2] = keccak256(bytes(abi.encode(user3, 2)));
        leaves[3] = keccak256(bytes(abi.encode(user4, 3)));
        bytes32 root = tree.getRoot(leaves);
        royalty = new RoyaltyNFT(root);
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

    function test_Merkle() public {
        bytes32[] memory proof = tree.getProof(leaves, 0);
        vm.prank(user1);
        royalty.purchaseWithDiscount{value: 1 ether}(0, proof);
    }

    function test_Merkle_Multiple_Users() public {
        vm.startPrank(user1);
        royalty.purchaseWithDiscount{value: 1 ether}(
            0,
            tree.getProof(leaves, 0)
        );
        vm.startPrank(user2);
        royalty.purchaseWithDiscount{value: 1 ether}(
            1,
            tree.getProof(leaves, 1)
        );
        vm.startPrank(user3);
        royalty.purchaseWithDiscount{value: 1 ether}(
            2,
            tree.getProof(leaves, 2)
        );
        vm.startPrank(user4);
        royalty.purchaseWithDiscount{value: 1 ether}(
            3,
            tree.getProof(leaves, 3)
        );
    }

    function test_Merkle_Insufficient_Funds() public {
        bytes32[] memory proof = tree.getProof(leaves, 0);
        vm.prank(user1);
        vm.expectRevert(RoyaltyNFT.InsufficientFunds.selector);
        royalty.purchaseWithDiscount{value: 0.9 ether}(0, proof);
    }

    function test_Merkle_Cannot_Claim_Twice() public {
        bytes32[] memory proof = tree.getProof(leaves, 0);
        vm.prank(user1);
        royalty.purchaseWithDiscount{value: 1 ether}(0, proof);
        vm.expectRevert(RoyaltyNFT.AlreadyClaimed.selector);
        royalty.purchaseWithDiscount{value: 1 ether}(0, proof);
    }

    function test_Merkle_Cannot_Claim_Someone_Elses() public {
        bytes32[] memory proof = tree.getProof(leaves, 0);
        vm.expectRevert(RoyaltyNFT.InvalidProof.selector);
        royalty.purchaseWithDiscount{value: 1 ether}(0, proof);
    }

    function test_Merkle_Cannot_Claim_Wrong_Index() public {
        bytes32[] memory proof = tree.getProof(leaves, 0);
        vm.expectRevert(RoyaltyNFT.InvalidProof.selector);
        royalty.purchaseWithDiscount{value: 1 ether}(1, proof);
    }
}
