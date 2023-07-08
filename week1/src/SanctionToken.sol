// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin/token/ERC20/ERC20.sol";
import "openzeppelin/access/Ownable.sol";

contract SanctionToken is ERC20, Ownable {
    constructor() ERC20("SanctionToken", "ST") {}
}
