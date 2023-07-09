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

    function test_Can_Create_Second_Escrow_Entry() public {
        assertEq(token.balanceOf(address(escrow)), 0);
        assertEq(escrow.numEntries(), 0);

        token.approve(address(escrow), 100 ether);
        escrow.createEscrow(address(token), user1, 70 ether);
        vm.warp(block.timestamp + 1 days);
        escrow.createEscrow(address(token), user2, 30 ether);
        (
            address _token,
            address _buyer,
            address _seller,
            uint256 _amount,
            uint256 _withdrawalTime,
            bool _withdrawn
        ) = escrow.escrowEntries(1);

        assertEq(_token, address(token));
        assertEq(_buyer, address(this));
        assertEq(_seller, user2);
        assertEq(_amount, 30 ether);
        assertEq(_withdrawalTime, block.timestamp + 3 days);
        assertEq(_withdrawn, false);

        assertEq(escrow.numEntries(), 2);
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

    function test_Withdraw_Funds_To_Different_Address() public {
        token.approve(address(escrow), 100 ether);
        escrow.createEscrow(address(token), user1, 100 ether);

        vm.warp(block.timestamp + 3 days);

        vm.prank(user1);
        escrow.withdraw(0, user2);

        assertEq(token.balanceOf(user2), 100 ether);
        assertEq(token.balanceOf(address(escrow)), 0);
    }

    function test_Cannot_Withdraw_Funds_Early() public {
        token.approve(address(escrow), 100 ether);
        escrow.createEscrow(address(token), user1, 100 ether);

        vm.warp(block.timestamp + 3 days - 1);
        vm.expectRevert(Escrow.WithdrawalTimeNotReached.selector);
        vm.prank(user1);
        escrow.withdraw(0, user1);
    }

    function test_Cannot_Withdraw_Funds_If_Not_Seller() public {
        token.approve(address(escrow), 100 ether);
        escrow.createEscrow(address(token), user1, 100 ether);

        vm.warp(block.timestamp + 3 days);

        vm.prank(user2);
        vm.expectRevert(Escrow.OnlySeller.selector);
        escrow.withdraw(0, user2);
    }

    function test_Cannot_Withdraw_Funds_Twice() public {
        token.approve(address(escrow), 100 ether);
        escrow.createEscrow(address(token), user1, 100 ether);

        vm.warp(block.timestamp + 3 days);

        vm.prank(user1);
        escrow.withdraw(0, user1);
        vm.prank(user1);
        vm.expectRevert(Escrow.EscrowAlreadyWithdrawn.selector);
        escrow.withdraw(0, user1);

        assertEq(token.balanceOf(user1), 100 ether);
        assertEq(token.balanceOf(address(escrow)), 0);
    }
}
