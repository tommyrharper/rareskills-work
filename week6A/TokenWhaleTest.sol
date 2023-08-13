// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.4.21;

import "./TokenWhaleChallenge.sol";

/// @dev Run the template with
///      ```
///      solc-select use 0.8.0
///      echidna week6/TokenWhaleTest.sol --contract TestTokenWhale --test-mode assertion
///      ```
///      or:
///      ```
///      echidna week6/TokenWhaleTest.sol --contract TestTokenWhale
///      ```
///      or by providing a config
///      ```
///      echidna week6/TokenWhaleTest.sol --contract TestTokenWhale --config week6/config.yaml
///      ```
contract TestTokenWhale is TokenWhaleChallenge {
    function echidna_test_token_whale() public view returns (bool) {
        // TODO: add the property
        return isComplete();
    }
}
