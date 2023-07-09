// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "openzeppelin/token/ERC20/IERC20.sol";
import "openzeppelin/token/ERC20/utils/SafeERC20.sol";

/// @notice Escrow contract that allows a buyer to lock tokens for 3 days before it can be claimed by the seller
contract Escrow {
    /*//////////////////////////////////////////////////////////////
                               LIBRARIES
    //////////////////////////////////////////////////////////////*/

    /// @dev use SafeERC20 to ensure transactions revert on failure
    using SafeERC20 for IERC20;

    /*//////////////////////////////////////////////////////////////
                               CONSTANTS
    //////////////////////////////////////////////////////////////*/

    /// @notice The period of time that must elapse before a seller can claim their funds
    uint256 public constant WAIT_TIME = 3 days;

    /*//////////////////////////////////////////////////////////////
                                 STATE
    //////////////////////////////////////////////////////////////*/

    /// @notice The total number of escrow entries that have been created
    uint256 public numEntries;

    /// @notice A mapping from escrow ids to the associated EscrowEntry structs
    mapping(uint256 => EscrowEntry) public escrowEntries;

    /// @notice Struct containing all the relevant info for a given escrow entry
    struct EscrowEntry {
        address token;
        address buyer;
        address seller;
        uint256 amount;
        uint256 withdrawalTime;
        bool withdrawn;
    }

    /*//////////////////////////////////////////////////////////////
                               FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Creates a new escrow entry between a buyer and seller
    /// @param _token The address of the token to be escrowed
    /// @param _seller The address of the seller
    /// @param _amount The amount of tokens to be escrowed
    function createEscrow(
        address _token,
        address _seller,
        uint256 _amount
    ) external {
        uint256 withdrawalTime = block.timestamp + WAIT_TIME;
        escrowEntries[numEntries] = EscrowEntry({
            token: _token,
            buyer: msg.sender,
            seller: _seller,
            amount: _amount,
            withdrawalTime: withdrawalTime,
            withdrawn: false
        });

        ++numEntries;

        emit EscrowCreated(
            numEntries - 1,
            msg.sender,
            _seller,
            _token,
            _amount
        );

        IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);
    }

    /// @notice Allows a seller to withdraw their funds after the withdrawal time has elapsed
    /// @param _entryId The id of the escrow entry to withdraw from
    /// @param _to The address to send the funds to
    function withdraw(uint256 _entryId, address _to) external {
        EscrowEntry storage entry = escrowEntries[_entryId];

        if (msg.sender != entry.seller) revert OnlySeller();
        if (entry.withdrawalTime > block.timestamp)
            revert WithdrawalTimeNotReached();
        if (entry.withdrawn) revert EscrowAlreadyWithdrawn();

        entry.withdrawn = true;

        emit EscrowWithdrawn(_entryId);

        IERC20(entry.token).safeTransfer(_to, entry.amount);
    }

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    /// @notice Emitted when a new escrow entry is created
    /// @param escrowId The id of the escrow entry
    /// @param buyer The address of the buyer
    /// @param seller The address of the seller
    /// @param token The address of the token being escrowed
    /// @param amount The amount of tokens being escrowed
    event EscrowCreated(
        uint256 indexed escrowId,
        address indexed buyer,
        address indexed seller,
        address token,
        uint256 amount
    );

    /// @notice Emitted when a seller withdraws their funds
    /// @param escrowId The id of the escrow entry
    event EscrowWithdrawn(uint256 escrowId);

    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/

    /// @notice Emitted someone other than the seller attempts to claim funds
    error OnlySeller();

    /// @notice Emitted when a seller attempts to withdraw funds before the withdrawal time has elapsed
    error WithdrawalTimeNotReached();

    /// @notice Emitted when a seller attempts to withdraw funds from an escrow entry that has already been withdrawn from
    error EscrowAlreadyWithdrawn();
}
