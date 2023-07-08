// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin/token/ERC20/ERC20.sol";

contract BondingToken is ERC20 {
    constructor() ERC20("BondingToken", "BT") {}
}
