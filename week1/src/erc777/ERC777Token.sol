// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "./ERC777.sol";

contract ERC777Token is ERC777 {
    constructor(
        string memory name_,
        string memory symbol_,
        address[] memory defaultOperators_
    ) ERC777(name_, symbol_, defaultOperators_) {}

    function mint(address to, uint256 amount) external {
        bytes memory empty = bytes("");
        _mint(to, amount, empty, empty);
    }
}
