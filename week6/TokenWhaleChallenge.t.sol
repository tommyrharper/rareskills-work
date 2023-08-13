// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.0;

// import "./token.sol";
import "./TokenWhaleChallenge.sol";

/// @dev Run the template with
///      ```
///      solc-select use 0.8.0
///      echidna ./week6/TokenWhaleChallenge.t.sol --contract TokenWhaleChallengeTest
///      ```
contract TokenWhaleChallengeTest is TokenWhaleChallenge {
    address echidna = tx.origin;

    constructor() {
        balances[echidna] = 10_000;
    }

    function echidna_test_balance() public view returns (bool) {
        // TODO: add the property
        return balances[echidna] <= 10000;
    }
}
