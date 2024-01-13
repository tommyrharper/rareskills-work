//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract Token is ERC20Permit {
    constructor(address _to) ERC20Permit("MyToken") ERC20("MyToken", "MT") {
        _mint(0x8E2f228c0322F872efAF253eF25d7F5A78d5851D, 1_000_000 * 10 ** decimals());
    }
}