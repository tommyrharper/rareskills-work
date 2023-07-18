// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "openzeppelin/token/ERC721/extensions/ERC721Royalty.sol";
import "openzeppelin/access/Ownable2Step.sol";

// merkle tree mint discount;
// use bitmap for mint discount
// ERC20 for staking rewards
// NFT staking contract that pays out staking rewards (10 ERC20 per day)
// // staked via safeTransfer
// funds withdrawable by Ownable2Step

contract RoyaltyNFT is ERC721Royalty, Ownable2Step {
    uint256 public number;

    constructor() ERC721("RoyaltyNFT", "RNFT") Ownable2Step() {
        _setDefaultRoyalty(msg.sender, 250);
        for (uint256 i = 0; i <= 20; i++) {
            _mint(msg.sender, i);
        }
    }
}
