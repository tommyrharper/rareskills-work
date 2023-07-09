// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "./TestHelpers.t.sol";
import "../src/Escrow.sol";

contract EscrowTest is TestHelpers {
    Escrow public escrow;
    address public user1;
    address public user2;

    function setUp() public {
        escrow = new Escrow();
        user1 = createUser();
        user2 = createUser();
    }

    function testSomething() public {}
}
