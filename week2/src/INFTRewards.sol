// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "openzeppelin/token/ERC20/IERC20.sol";

interface INFTRewards is IERC20 {
    function setNFTStaking(address _nftStaking) external;
    function mint(address to, uint256 amount) external;
}
