// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

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

    error MustPayGreaterThanZero();
}
