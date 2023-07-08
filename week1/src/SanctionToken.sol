// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin/token/ERC20/ERC20.sol";
import "openzeppelin/access/Ownable.sol";

contract SanctionToken is ERC20, Ownable {
    mapping(address => bool) public blackList;

    constructor() ERC20("SanctionToken", "ST") {}

    function ban(address _account, bool _banned) external onlyOwner {
        blackList[_account] = _banned;
    }
}
