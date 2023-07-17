// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "openzeppelin/token/ERC721/extensions/ERC721Royalty.sol";

contract RoyaltyNFT is ERC721Royalty {
    uint256 public number;

    constructor() ERC721("RoyaltyNFT", "RNFT") {}
}
