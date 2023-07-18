// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "openzeppelin/token/ERC721/extensions/ERC721Wrapper.sol";
import "openzeppelin/token/ERC20/IERC20.sol";
import "openzeppelin/token/ERC721/IERC721.sol";
import "openzeppelin/token/ERC721/IERC721Receiver.sol";
import "./INFTRewards.sol";

contract NFTStaking is IERC721Receiver {
    INFTRewards public immutable nftRewards;
    IERC721 public immutable royaltyNFT;

    mapping(uint256 => address) public ownerOf;
    mapping(uint256 => uint256) public stakedAt;

    constructor(address _nftRewards, address _royaltyNFT) {
        nftRewards = INFTRewards(_nftRewards);
        royaltyNFT = IERC721(_royaltyNFT);
    }

    function claimRewards(uint256 tokenId) external {
        require(
            ownerOf[tokenId] == msg.sender,
            "Only owner can claim rewards."
        );
        uint256 stakedAt_ = stakedAt[tokenId];
        require(stakedAt_ > 0, "Token not staked.");
        uint256 rewards = ((block.timestamp - stakedAt_) * 10 ether) / 1 days;
        stakedAt[tokenId] = block.timestamp;
        nftRewards.mint(msg.sender, rewards);
    }

    function claimNFT(uint256 tokenId) external {
        require(
            ownerOf[tokenId] == msg.sender,
            "Only owner can claim NFT."
        );
        ownerOf[tokenId] = address(0);
        stakedAt[tokenId] = 0;
        royaltyNFT.safeTransferFrom(address(this), msg.sender, tokenId);
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes memory data
    ) public virtual override returns (bytes4) {
        require(
            msg.sender == address(royaltyNFT),
            "Only RoyaltyNFT can stake."
        );
        ownerOf[tokenId] = from;
        stakedAt[tokenId] = block.timestamp;
        return IERC721Receiver.onERC721Received.selector;
    }
}
