// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "openzeppelin/token/ERC20/ERC20.sol";
import "openzeppelin/access/Ownable.sol";

/// @notice Token that can black list users preventing them from transacting
contract SanctionToken is ERC20, Ownable {
    /*//////////////////////////////////////////////////////////////
                                 STATE
    //////////////////////////////////////////////////////////////*/

    /// @notice mapping of user address to whether or not they are blacklisted
    mapping(address => bool) public blackList;

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    /// @dev sets the msg.sender to be the owner of the contract and mints 1000 eth tokens to msg.sender
    constructor() ERC20("SanctionToken", "ST") {
        _mint(msg.sender, 1000 ether);
    }

    /*//////////////////////////////////////////////////////////////
                               FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Ban or unban a given user
    /// @param _account the address of the user to ban or unban
    /// @param _banned whether or not the user should be banned
    function ban(address _account, bool _banned) external onlyOwner {
        blackList[_account] = _banned;
        emit UserBanStatusUpdated(_account, _banned);
    }

    /// @dev Override the _beforeTokenTransfer function to prevent banned users from transacting
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal view override {
        if (blackList[to]) revert BannedToAddress(to);
        if (blackList[from]) revert BannedFromAddress(from);
    }

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    /// @notice emitted when a user is banned or unbanned
    /// @param account the address of the user that was banned or unbanned
    /// @param banned whether or not the user is banned
    event UserBanStatusUpdated(address account, bool banned);

    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/

    /// @notice Error message when a transfer is made to a banned address
    /// @param to the address that is banned
    error BannedToAddress(address to);

    /// @notice Error message when a transfer is made from a banned address
    /// @param from the address that is banned
    error BannedFromAddress(address from);
}
