// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// TODO: remove this
import {Test, console} from "forge-std/Test.sol";

import "openzeppelin/token/ERC20/ERC20.sol";
import "openzeppelin/utils/math/Math.sol";

contract BondingToken is ERC20 {
    uint256 public reserveBalance;

    constructor() ERC20("BondingToken", "BT") {}

    function purchase(uint256 maxEntryPrice) external payable {
        uint256 _totalSupply = totalSupply();

        if (_totalSupply > maxEntryPrice) revert MaxSlippageExceeded();
        if (msg.value == 0) revert MustPayGreaterThanZero();

        reserveBalance += msg.value;

        uint256 newSupply = Math.sqrt(2 * reserveBalance);
        uint256 supplyChange = newSupply - _totalSupply;

        if (supplyChange == 0) revert TradeTooSmall();

        _mint(msg.sender, supplyChange);
    }

    function sell(uint256 amount, uint256 minExitPrice) external {
        uint256 _totalSupply = totalSupply();

        if (_totalSupply < minExitPrice) revert MaxSlippageExceeded();
        if (amount == 0) revert MustSellGreaterThanZero();
        if (amount > balanceOf(msg.sender)) revert InsufficientBalance();

        uint256 newTotalSupply = _totalSupply - amount;
        uint256 newReserveBalance = (newTotalSupply ** 2) / 2;
        uint256 changeInReserves = reserveBalance - newReserveBalance;

        _burn(msg.sender, amount);
        reserveBalance = newReserveBalance;

        (bool success, ) = payable(address(msg.sender)).call{
            value: changeInReserves
        }("");

        if (!success) revert PayoutFailed();
    }

    error TradeTooSmall();
    error MaxSlippageExceeded();
    error PayoutFailed();
    error MustPayGreaterThanZero();
    error MustSellGreaterThanZero();
    error InsufficientBalance();
}
