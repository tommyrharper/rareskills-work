// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "openzeppelin/token/ERC721/extensions/ERC721Royalty.sol";
import "openzeppelin/access/Ownable2Step.sol";
import "openzeppelin/utils/structs/BitMaps.sol";
import "openzeppelin/utils/cryptography/MerkleProof.sol";
import "openzeppelin/utils/cryptography/ECDSA.sol";

// add max supply 20
// merkle tree mint discount;
// use bitmap for mint discount
// ERC20 for staking rewards
// NFT staking contract that pays out staking rewards (10 ERC20 per day)
// // staked via safeTransfer
// funds withdrawable by Ownable2Step

contract RoyaltyNFT is ERC721Royalty, Ownable2Step {
    using ECDSA for bytes32;
    using BitMaps for BitMaps.BitMap;

    bytes32 public immutable merkleRoot;
    BitMaps.BitMap internal bitMap;
    uint256 public totalSupply;

    constructor(
        bytes32 _merkleRoot
    ) ERC721("RoyaltyNFT", "RNFT") Ownable2Step() {
        merkleRoot = _merkleRoot;
        _setDefaultRoyalty(msg.sender, 250);
    }

    function isClaimed(uint256 index) public view returns (bool) {
        return bitMap.get(index);
    }

    function _setClaimed(uint256 index) private {
        bitMap.setTo(index, true);
    }

    function purchaseWithDiscount(
        uint256 index,
        bytes32[] calldata merkleProof
    ) external payable {
        if (msg.value < 1 ether) revert InsufficientFunds();
        if (isClaimed(index)) revert AlreadyClaimed();

        bytes32 node = keccak256(bytes(abi.encode(msg.sender, index)));
        if (!MerkleProof.verify(merkleProof, merkleRoot, node))
            revert InvalidProof();

        _setClaimed(index);
        _mint(msg.sender, totalSupply);
        totalSupply++;

        emit Claimed(index, msg.sender);
    }

    error InsufficientFunds();
    error InvalidProof();
    error AlreadyClaimed();
    // This event is triggered whenever a call to #claim succeeds.
    event Claimed(uint256 index, address account);
}
