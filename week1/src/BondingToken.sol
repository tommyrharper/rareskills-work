// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "openzeppelin/token/ERC20/ERC20.sol";
import "erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol";
import "erc1363-payable-token/contracts/token/ERC1363/IERC1363Receiver.sol";
import "openzeppelin/utils/math/Math.sol";

/// @notice Bonding token with a linear bonding curve of price = total_supply
contract BondingToken is ERC1363, IERC1363Receiver {
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
    constructor() ERC20("BondingToken", "BT") {}

    /*//////////////////////////////////////////////////////////////
                               FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Purchase tokens with eth
    /// @param to the address to mint the new tokens to
    /// @param maxEntryPrice the maximum price per token that the user is willing to begin purchasing tokens at
    /// @dev Note: that the maxEntryPrice is not the price that a user will get their tokens at, as the price will be pushed
    ///  up the bonding curve by the price impact of this transaction. This is simply the max price allowed before this purchase executes
    function purchase(address to, uint256 maxEntryPrice) external payable {
        uint256 _totalSupply = totalSupply();

        if (_totalSupply > maxEntryPrice) revert MaxSlippageExceeded();
        if (msg.value == 0) revert MustPayGreaterThanZero();

        reserveBalance += msg.value;

        /// @dev max reserveBalance is type(uint256).max / 2
        /// As this is an unrealistic amount of eth, this should never be reached
        uint256 newSupply = Math.sqrt(2 * reserveBalance);
        uint256 supplyChange = newSupply - _totalSupply;

        if (supplyChange == 0) revert PurchaseTooSmall();

        _mint(to, supplyChange);
    }

    /// @notice Sell tokens for eth
    /// @param to the address to send the eth to
    /// @param amount the amount of tokens to sell
    /// @param minExitPrice the minimum price per token that the user is willing to begin selling tokens at
    /// @dev Note: again, the sale price is not garuanteed to be better than minExitPrice, minExitPrice is the price
    /// that is acceptable for this user before the price impact of this sale is taken into account
    function sell(address to, uint256 amount, uint256 minExitPrice) public {
        _sell(msg.sender, to, amount, minExitPrice);
    }

    function _sell(
        address seller,
        address to,
        uint256 amount,
        uint256 minExitPrice
    ) internal {
        uint256 _totalSupply = totalSupply();

        if (_totalSupply < minExitPrice) revert MaxSlippageExceeded();
        if (amount == 0) revert MustSellGreaterThanZero();
        if (amount > balanceOf(seller)) revert InsufficientBalance();

        uint256 newTotalSupply = _totalSupply - amount;
        uint256 newReserveBalance = (newTotalSupply ** 2) / 2;
        uint256 changeInReserves = reserveBalance - newReserveBalance;

        _burn(seller, amount);
        reserveBalance = newReserveBalance;

        (bool success, ) = payable(address(to)).call{value: changeInReserves}(
            ""
        );

        if (!success) revert PayoutFailed();
    }

    /// @notice Called when a user invokes transferAndCall to this contract address
    /// @param spender address The address which called `transferAndCall` or `transferFromAndCall` function
    /// @param sender address The address which are token transferred from
    /// @param amount uint256 the amount of tokens transferred
    /// @param data bytes Additional data with no specified format
    /// @dev the data param is expected to be a 32 byte uint representing the minExitPrice
    /// @dev tokens will be sent to the sender address
    function onTransferReceived(
        address spender,
        address sender,
        uint256 amount,
        bytes calldata data
    ) public returns (bytes4) {
        if (data.length != 32) revert InvalidMinExitPriceData();
        uint256 minExitPrice = uint256(bytes32(data));

        _sell(address(this), sender, amount, minExitPrice);

        return IERC1363Receiver.onTransferReceived.selector;
    }

    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/

    /// @notice The user must specify a minExitPrice in data field
    error InvalidMinExitPriceData();

    /// @notice If no tokens are generated by the purchase, it will revert to save the buyer wasting their ether
    error PurchaseTooSmall();

    /// @notice The transaction will revert if the slippage exceeds the users maxEntryPrice or minExitPrice
    error MaxSlippageExceeded();

    /// @notice The transaction to payout ether failed
    error PayoutFailed();

    /// @notice You cannot purchase with zero ether
    error MustPayGreaterThanZero();

    /// @notice You cannot sell zero tokens
    error MustSellGreaterThanZero();

    /// @notice The user has insufficient tokens to execute the sale
    error InsufficientBalance();
}
