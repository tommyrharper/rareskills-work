// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "openzeppelin/token/ERC721/extensions/ERC721Wrapper.sol";
import "openzeppelin/token/ERC20/IERC20.sol";
import "openzeppelin/token/ERC721/IERC721.sol";

contract NFTStaking is ERC721Wrapper {
    IERC20 public immutable nftRewards;

    constructor(
        address _nftRewards,
        IERC721 _royaltyNFT
    ) ERC721Wrapper(_royaltyNFT) ERC721("StakedRoyaltyNFT", "SRT") {
        nftRewards = IERC20(_nftRewards);
    }
}
