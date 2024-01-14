// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";

contract TestHelpers is Test {
    function _deriveEIP712Digest(
        bytes32 domainSeparator,
        bytes32 hashStruct
    ) internal pure returns (bytes32 value) {
        value = keccak256(
            abi.encodePacked(uint16(0x1901), domainSeparator, hashStruct)
        );
    }
}
