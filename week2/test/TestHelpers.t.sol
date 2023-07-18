// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";

contract TestHelpers is Test {
    uint256 internal userNonce;
    uint256 internal nonce;

    function createAndDealUser() internal returns (address) {
        address user = createUser();
        vm.deal(user, 100 ether);
        return user;
    }

    function createAndDealUser(uint256 amount) internal returns (address) {
        address user = createUser();
        vm.deal(user, amount);
        return user;
    }

    /// @dev create a new user address
    function createUser() internal returns (address) {
        userNonce++;
        return vm.addr(userNonce);
    }

    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}
