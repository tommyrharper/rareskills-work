// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "openzeppelin/token/ERC721/extensions/ERC721Enumerable.sol";
import "openzeppelin/utils/math/Math.sol";

contract PrimeNFTs is ERC721Enumerable {
    constructor() ERC721("PrimeNFTs", "PNFTs") {}

    function mint(address to, uint256 tokenId) external {
        _mint(to, tokenId);
    }
}
