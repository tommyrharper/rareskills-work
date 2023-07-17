// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "openzeppelin/token/ERC721/extensions/ERC721Royalty.sol";

contract RoyaltyNFT is ERC721Royalty {
    uint256 public number;

    constructor() ERC721("RoyaltyNFT", "RNFT") {
        _setDefaultRoyalty(msg.sender, 250);
        for (uint256 i = 0; i <= 20; i++) {
            _mint(msg.sender, i);
        }
    }
}
