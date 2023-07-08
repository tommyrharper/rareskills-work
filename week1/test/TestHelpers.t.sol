// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";

contract TestHelpers is Test {
    uint256 public userNonce;
    uint256 public nonce;

    /// @dev create a new user address
    function createUser() public returns (address) {
        userNonce++;
        return vm.addr(userNonce);
    }
}
