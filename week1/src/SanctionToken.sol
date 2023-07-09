// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "openzeppelin/token/ERC20/ERC20.sol";
import "openzeppelin/access/Ownable.sol";

contract SanctionToken is ERC20, Ownable {
    mapping(address => bool) public blackList;

    constructor() ERC20("SanctionToken", "ST") {
        _mint(msg.sender, 1000 ether);
    }

    function ban(address _account, bool _banned) external onlyOwner {
        blackList[_account] = _banned;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal view override {
        if (blackList[to]) revert BannedToAddress(to);
        if (blackList[from]) revert BannedFromAddress(from);
    }

    error BannedToAddress(address to);
    error BannedFromAddress(address from);
}
