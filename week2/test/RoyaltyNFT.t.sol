// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {TestHelpers} from "./TestHelpers.t.sol";
import "../src/RoyaltyNFT.sol";
import "../src/NFTRewards.sol";
import "../src/NFTStaking.sol";
import "murky/Merkle.sol";

contract RoyaltyNFTTest is TestHelpers {
    /*//////////////////////////////////////////////////////////////
                                 STATE
    //////////////////////////////////////////////////////////////*/

    RoyaltyNFT public royalty;
    Merkle public tree;

    NFTStaking public nftStaking;
    NFTRewards public nftRewards;

    address internal user1;
    address internal user2;
    address internal user3;
    address internal user4;
    address internal user5;
    bytes32[] internal leaves = new bytes32[](4);

    /*//////////////////////////////////////////////////////////////
                                 SETUP
    //////////////////////////////////////////////////////////////*/

    function setUp() public {
        user1 = createAndDealUser(1000 ether);
        user2 = createAndDealUser(1000 ether);
        user3 = createAndDealUser(1000 ether);
        user4 = createAndDealUser(1000 ether);
        user5 = createUser();

        tree = new Merkle();
        leaves[0] = keccak256(bytes(abi.encode(user1, 0)));
        leaves[1] = keccak256(bytes(abi.encode(user2, 1)));
        leaves[2] = keccak256(bytes(abi.encode(user3, 2)));
        leaves[3] = keccak256(bytes(abi.encode(user4, 3)));
        bytes32 root = tree.getRoot(leaves);
        royalty = new RoyaltyNFT(root, 4);

        nftRewards = new NFTRewards();
        nftStaking = new NFTStaking(address(nftRewards), address(royalty));
        nftRewards.setNFTStaking(address(nftStaking));
    }

    /*//////////////////////////////////////////////////////////////
                              BASIC TESTS
    //////////////////////////////////////////////////////////////*/

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

    /*//////////////////////////////////////////////////////////////
                              MERKLE TESTS
    //////////////////////////////////////////////////////////////*/

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

    /*//////////////////////////////////////////////////////////////
                             PURCHASE TESTS
    //////////////////////////////////////////////////////////////*/

    function test_Purchase() public {
        vm.prank(user1);
        royalty.purchase{value: 10 ether}();
    }

    function test_Max_Purchases() public {
        for (uint256 i = 0; i < 16; i++) {
            vm.prank(user1);
            royalty.purchase{value: 10 ether}();
        }
        vm.prank(user1);
        vm.expectRevert(RoyaltyNFT.MaxMinted.selector);
        royalty.purchase{value: 10 ether}();
    }

    function test_Purchase_Insufficient_Funds() public {
        vm.prank(user1);
        vm.expectRevert(RoyaltyNFT.InsufficientFunds.selector);
        royalty.purchase{value: 9 ether}();
    }

    function test_Reclaim_Funds() public {
        vm.prank(user1);
        royalty.purchase{value: 10 ether}();
        royalty.withdrawFunds(user5);
        assertEq(user5.balance, 10 ether);
    }

    /*//////////////////////////////////////////////////////////////
                             STAKING TESTS
    //////////////////////////////////////////////////////////////*/

    function test_Stake_NFT() public {
        vm.prank(user1);
        royalty.purchase{value: 10 ether}();

        vm.prank(user1);
        royalty.safeTransferFrom(user1, address(nftStaking), 4);
        assertEq(royalty.balanceOf(address(nftStaking)), 1);
        assertEq(nftStaking.ownerOf(4), user1);
        assertEq(nftStaking.stakedAt(4), block.timestamp);

        vm.prank(user1);
        nftStaking.claimRewards(4);
        assertEq(nftRewards.balanceOf(user1), 0);

        vm.warp(block.timestamp + 1 days);
        vm.prank(user1);
        nftStaking.claimRewards(4);
        assertEq(nftRewards.balanceOf(user1), 10 ether);

        vm.warp(block.timestamp + 1 days);
        vm.prank(user1);
        nftStaking.claimRewards(4);
        assertEq(nftRewards.balanceOf(user1), 20 ether);

        vm.warp(block.timestamp + 2.5 days);
        vm.prank(user1);
        nftStaking.claimRewards(4);
        assertEq(nftRewards.balanceOf(user1), 45 ether);

        vm.prank(user1);
        nftStaking.unstake(4);
        assertEq(royalty.balanceOf(address(nftStaking)), 0);
        assertEq(royalty.balanceOf(user1), 1);
        assertEq(nftStaking.ownerOf(4), address(0));
        assertEq(nftStaking.stakedAt(4), 0);

        vm.prank(user1);
        vm.expectRevert();
        nftStaking.claimRewards(4);
    }

    function test_Stake_NFT_Edge_Cases() public {
        vm.prank(user1);
        royalty.purchase{value: 10 ether}();

        vm.prank(user1);
        royalty.safeTransferFrom(user1, address(nftStaking), 4);
        assertEq(royalty.balanceOf(address(nftStaking)), 1);
        assertEq(nftStaking.ownerOf(4), user1);
        assertEq(nftStaking.stakedAt(4), block.timestamp);

        vm.prank(user1);
        vm.expectRevert();
        nftStaking.claimRewards(5);
        vm.prank(user2);
        vm.expectRevert();
        nftStaking.unstake(4);
    }
}
