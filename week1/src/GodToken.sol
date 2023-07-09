// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "openzeppelin/token/ERC20/ERC20.sol";
import "openzeppelin/access/Ownable.sol";

/// @notice A token that allows a "God Mode" for the owner of the contract who can transfer anyones balance to anyone
contract GodToken is ERC20, Ownable {
    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    /// @dev Sets the owner to the msg.sender and mints the msg.sender 1000 ether of tokens
    constructor() ERC20("GodToken", "GT") {
        _mint(msg.sender, 1000 ether);
    }

    /*//////////////////////////////////////////////////////////////
                               FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @dev This overrides ERC20._spendAllowance function to ensure the owner approved balance is not checked
    function _spendAllowance(
        address _owner,
        address _spender,
        uint256 _amount
    ) internal override {
        if (msg.sender != owner()) {
            super._spendAllowance(_owner, _spender, _amount);
        }
    }
}
