// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin/token/ERC20/ERC20.sol";
import "openzeppelin/access/Ownable.sol";

contract GodToken is ERC20, Ownable {
    constructor() ERC20("GodToken", "GT") {
        _mint(msg.sender, 1000 ether);
    }

    function _spendAllowance(
        address _owner,
        address _spender,
        uint256 _amount
    ) internal override {
        if (msg.sender != owner()) {
            super._spendAllowance(_owner, _spender, _amount);
        }
    }
}
