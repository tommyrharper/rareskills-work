// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {GatekeeperOne, GatekeeperOneAttacker} from "../src/GatekeeperOne.sol";

contract GatekeeperOneTest is Test {
    GatekeeperOne public gateKeeper;

    function setUp() public {
        gateKeeper = new GatekeeperOne();
    }

    function testAttack() public {
        GatekeeperOneAttacker attacker = new GatekeeperOneAttacker(gateKeeper);
        attacker.attack();
        assertEq(gateKeeper.entrant(), tx.origin);
    }
}
