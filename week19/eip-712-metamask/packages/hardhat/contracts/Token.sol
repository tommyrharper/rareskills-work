//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract Token is ERC20Permit {
    constructor(address _to) ERC20Permit("MyToken") ERC20("MyToken", "MT") {
        _mint(_to, 1_000_000 * 10 ** decimals());
    }
}