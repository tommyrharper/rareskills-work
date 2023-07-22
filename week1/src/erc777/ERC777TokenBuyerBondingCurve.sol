// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "openzeppelin/token/ERC20/ERC20.sol";
import "./IERC777Recipient.sol";
import "openzeppelin/utils/math/Math.sol";
import "openzeppelin/utils/introspection/IERC1820Registry.sol";

/// @notice Bonding token with a linear bonding curve of price = total_supply
/// @notice this contract simply sells the underlying ERC20 token for any ERC777 token
/// @notice this contract will not buy back the underlying ERC20 token
contract ERC777TokenBuyerBondingCurve is ERC20, IERC777Recipient {
    /*//////////////////////////////////////////////////////////////
                                 STATE
    //////////////////////////////////////////////////////////////*/

    /// @notice Total eth reserve balance
    /// @dev This value will not necessarily equal the contract balance due to the possible for force sending eth to the contract
    uint256 public reserveBalance;

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    /// @notice Instantiates the contract with the name and symbol
    constructor() ERC20("ERC777TokenBuyerBondingCurve", "BT") {
        IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24)
            .setInterfaceImplementer(
                address(this),
                keccak256("ERC777TokensRecipient"),
                address(this)
            );
    }

    /*//////////////////////////////////////////////////////////////
                               FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function tokensReceived(
        address operator,
        address from,
        address to,
        uint amount,
        bytes memory userData,
        bytes memory operatorData
    ) external {
        if (userData.length != 32) revert InvalidMaxEntryPriceData();
        uint256 maxEntryPrice = uint256(bytes32(userData));

        purchase(from, maxEntryPrice, amount);
    }

    /// @notice Purchase tokens with an erc777 token
    /// @param to the address to mint the new tokens to
    /// @param maxEntryPrice the maximum price per token that the user is willing to begin purchasing tokens at
    /// @param amount amount of tokens sent to the contract
    /// @dev Note: that the maxEntryPrice is not the price that a user will get their tokens at, as the price will be pushed
    ///  up the bonding curve by the price impact of this transaction. This is simply the max price allowed before this purchase executes
    function purchase(
        address to,
        uint256 maxEntryPrice,
        uint256 amount
    ) internal {
        uint256 _totalSupply = totalSupply();

        if (_totalSupply > maxEntryPrice) revert MaxSlippageExceeded();
        if (amount == 0) revert MustPayGreaterThanZero();

        reserveBalance += amount;

        uint256 newSupply = Math.sqrt(2 * reserveBalance);
        uint256 supplyChange = newSupply - _totalSupply;

        if (supplyChange == 0) revert PurchaseTooSmall();

        _mint(to, supplyChange);
    }

    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/

    /// @notice The user must specify a minExitPrice in data field
    error InvalidMaxEntryPriceData();

    /// @notice If no tokens are generated by the purchase, it will revert to save the buyer wasting their ether
    error PurchaseTooSmall();

    /// @notice The transaction will revert if the slippage exceeds the users maxEntryPrice or minExitPrice
    error MaxSlippageExceeded();

    /// @notice You cannot purchase with zero ether
    error MustPayGreaterThanZero();
}