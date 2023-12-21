// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Preservation, LibraryContract} from "../src/Preservation.sol";

contract PreservationTest is Test {
    LibraryContract internal libraryContract1;
    LibraryContract internal libraryContract2;
    Preservation internal preservation;
    address internal attacker;

    function setUp() public {
        attacker = address(0x1);

        libraryContract1 = new LibraryContract();
        libraryContract2 = new LibraryContract();
        preservation = new Preservation(
            address(libraryContract1),
            address(libraryContract2)
        );
    }

    function test_Attack() public {

    }
}
