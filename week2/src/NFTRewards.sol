// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "openzeppelin/token/ERC20/ERC20.sol";
import "openzeppelin/access/Ownable2Step.sol";
import "openzeppelin/token/ERC721/IERC721.sol";

contract NFTRewards is ERC20, Ownable2Step {
    IERC721 public nftStaking;

    constructor() ERC20("NFTRewards", "NFTR") {}

    modifier onlyNFTStaking() {
        require(msg.sender == address(nftStaking), "Only NFTStaking can mint.");
        _;
    }

    function setNFTStaking(address _nftStaking) external onlyOwner {
        nftStaking = IERC721(_nftStaking);
    }

    function mint(uint256 amount, address to) external onlyNFTStaking {
        _mint(to, amount);
    }
}
