// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../contracts/Dex.sol";
import "../node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";

/// @dev Run the template with
///      ```
///      solc-select use 0.8.20
///      echidna ./test/Dex.t.sol --contract DexTest
///      echidna ./week6/dex/test/Dex.t.sol --contract DexTest
///      ```
contract DexTest is Dex {
    address echidna = tx.origin;

    constructor() {
        // setTokens()
    }

    function echidna_test_dex() public view returns (bool) {
        return true;
    }
}
