// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../contracts/Dex.sol";
import "../node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";

contract MintableERC20 is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function mint(address account, uint256 amount) public {
        _mint(account, amount);
    }
}

/// @dev Run the template with
///      ```
///      solc-select use 0.8.20
///      echidna ./test/Dex.t.sol --contract DexTest
///      echidna ./week6/dex/test/Dex.t.sol --contract DexTest
///      ```
contract DexTest is Dex {
    address echidna = tx.origin;

    constructor() {
        MintableERC20 _token1 = new MintableERC20("Token1", "T1");
        MintableERC20 _token2 = new MintableERC20("Token2", "T2");
        setTokens(address(_token1), address(_token2));

        _token1.mint(address(this), 100 ether);
        _token2.mint(address(this), 100 ether);
        _token1.mint(msg.sender, 1 ether);
        _token2.mint(msg.sender, 1 ether);

        renounceOwnership();
    }

    function echidna_test_dex() public view returns (bool) {
        return
            ERC20(token1).balanceOf(address(this)) > 10 ether &&
            ERC20(token2).balanceOf(address(this)) > 10 ether;
    }
}
