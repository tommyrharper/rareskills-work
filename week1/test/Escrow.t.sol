// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "./TestHelpers.t.sol";
import "../src/Escrow.sol";
import "./MintableToken.t.sol";

contract EscrowTest is TestHelpers {
    /*//////////////////////////////////////////////////////////////
                                 STATE
    //////////////////////////////////////////////////////////////*/

    Escrow public escrow;
    MintableToken public token;
    address public user1;
    address public user2;

    /*//////////////////////////////////////////////////////////////
                                 SETUP
    //////////////////////////////////////////////////////////////*/

    function setUp() public {
        escrow = new Escrow();
        token = new MintableToken();
        user1 = createUser();
        user2 = createUser();

        token.mint(address(this), 100 ether);
    }

    /*//////////////////////////////////////////////////////////////
                          CREATE ESCROW TESTS
    //////////////////////////////////////////////////////////////*/

    function test_Create_Escrow_Entry() public {
        assertEq(token.balanceOf(address(escrow)), 0);
        assertEq(escrow.numEntries(), 0);

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

        assertEq(escrow.numEntries(), 1);
        assertEq(token.balanceOf(address(escrow)), 100 ether);
    }

    function test_Cannot_Create_Escrow_Without_Approval() public {
        vm.expectRevert("ERC20: insufficient allowance");
        escrow.createEscrow(address(token), user1, 100 ether);
    }

    function test_Cannot_Create_Entry_With_EOA_Token_Address() public {
        vm.expectRevert("Address: call to non-contract");
        escrow.createEscrow(user2, user1, 100 ether);
    }

    /*//////////////////////////////////////////////////////////////
                            WITHDRAWAL TESTS
    //////////////////////////////////////////////////////////////*/

    function test_Withdraw_Funds() public {
        token.approve(address(escrow), 100 ether);
        escrow.createEscrow(address(token), user1, 100 ether);

        vm.warp(block.timestamp + 3 days);
        
        vm.prank(user1);
        escrow.withdraw(0, user1);

        assertEq(token.balanceOf(user1), 100 ether);
        assertEq(token.balanceOf(address(escrow)), 0);
    }
}
