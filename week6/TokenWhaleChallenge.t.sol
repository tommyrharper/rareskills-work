// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.4.21;

import "./TokenWhaleChallenge.sol";

/// @dev Run the template with
///      ```
///      solc-select use 0.8.0
///      echidna ./week6/TokenWhaleChallenge.t.sol --contract TokenWhaleChallengeTest
///      ```
contract TokenWhaleChallengeTest is TokenWhaleChallenge {
    address echidna = tx.origin;

    function TokenWhaleChallengeTest() public TokenWhaleChallenge(msg.sender) {}

    function echidna_test_balance() public view returns (bool) {
        return !isComplete();
    }
}

// Example failure:

// 0x1000 = A
// 0x3000 = B
// 0x2ffffd = C

// START B => balance = 1000

// B => approve(A, 999)
// A => transferFrom(B, C, 685)
// A => transfer(B, 999_999)

// Bug explained:
// `transferFrom` doesn't send tokens using `from` address