// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// TODO: remove this
import {Test, console} from "forge-std/Test.sol";

import "openzeppelin/token/ERC20/ERC20.sol";
import "openzeppelin/utils/math/Math.sol";

contract BondingToken is ERC20 {
    uint256 public reserveBalance;

    constructor() ERC20("BondingToken", "BT") {}

    function purchase() external payable {
        if (msg.value == 0) revert MustPayGreaterThanZero();

        reserveBalance += msg.value;

        uint256 newSupply = Math.sqrt(2 * reserveBalance);
        uint256 supplyChange = newSupply - totalSupply();

        _mint(msg.sender, supplyChange);
    }

    function sell(uint256 amount) external {
        if (amount == 0) revert MustSellGreaterThanZero();
        if (amount > balanceOf(msg.sender)) revert InsufficientBalance();

        uint256 newTotalSupply = totalSupply() - amount;
        uint256 newReserveBalance = (newTotalSupply ** 2) / 2;
        uint256 changeInReserves = reserveBalance - newReserveBalance;

        _burn(msg.sender, amount);
        reserveBalance = newReserveBalance;

        (bool success, ) = payable(address(msg.sender)).call{
            value: changeInReserves
        }("");

        if (!success) revert PayoutFailed();
    }

    error PayoutFailed();
    error MustPayGreaterThanZero();
    error MustSellGreaterThanZero();
    error InsufficientBalance();
}
