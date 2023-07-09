// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "./TestHelpers.t.sol";
import "../src/Escrow.sol";
import "./MintableToken.t.sol";

contract EscrowTest is TestHelpers {
    Escrow public escrow;
    MintableToken public token;
    address public user1;
    address public user2;

    function setUp() public {
        escrow = new Escrow();
        token = new MintableToken();
        user1 = createUser();
        user2 = createUser();

        token.mint(address(this), 100 ether);
    }

    function test_Create_Escrow_Entry() public {
        token.approve(address(escrow), 100 ether);
        escrow.createEscrow(address(token), user1, 100 ether);
        (
            address _token,
            address _buyer,
            address _seller,
            uint256 _amount,
            uint256 _withdrawalTime,
            bool _withdrawn
        ) = escrow.escrowEntries(0);

        assertEq(_token, address(token));
        assertEq(_buyer, address(this));
        assertEq(_seller, user1);
        assertEq(_amount, 100 ether);
        assertEq(_withdrawalTime, block.timestamp + 3 days);
        assertEq(_withdrawn, false);
    }
}
