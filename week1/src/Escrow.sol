// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "openzeppelin/token/ERC20/IERC20.sol";
import "openzeppelin/token/ERC20/utils/SafeERC20.sol";

contract Escrow {
    using SafeERC20 for IERC20;

    uint256 public constant WAIT_TIME = 3 days;

    uint256 public numEntries;
    mapping(uint256 => EscrowEntry) public escrowEntries;

    struct EscrowEntry {
        address token;
        address buyer;
        address seller;
        uint256 amount;
        uint256 withdrawalTime;
        bool withdrawn;
    }

    function createEscrow(
        address _token,
        address _seller,
        uint256 _amount
    ) external {
        IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);
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
    }

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

    event EscrowCreated(
        uint256 indexed escrowId,
        address indexed buyer,
        address indexed seller,
        address token,
        uint256 amount
    );
    event EscrowWithdrawn(uint256 escrowId);

    error OnlySeller();
    error WithdrawalTimeNotReached();
    error EscrowAlreadyWithdrawn();
}
