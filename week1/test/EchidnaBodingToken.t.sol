// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../src/BondingToken.sol";
import "openzeppelin/utils/math/Math.sol";

/// @dev Run the template with
///      ```
///      solc-select use 0.8.20
///      echidna ./ --contract EchidnaBodingToken
///      echidna ./week1 --contract EchidnaBodingToken
///      ```
contract EchidnaBodingToken is BondingToken {
    function echidna_test_sufficient_eth_for_reserve()
        public
        view
        returns (bool)
    {
        return reserveBalance >= address(this).balance;
    }

    function echidna_reserve_balance_close_to_square_of_total_supply_div_2()
        public
        view
        returns (bool)
    {
        uint expectedReserves = (totalSupply() ** 2) / 2;
        return
            closeTo(
                expectedReserves,
                reserveBalance,
                100 + (reserveBalance * 5) / 100
            );
    }

    function echidna_total_supply_sqrt_2x_reserve_balance()
        public
        view
        returns (bool)
    {
        uint256 expectedSupply = Math.sqrt(2 * reserveBalance);
        uint256 _totalSupply = totalSupply();
        return
            closeTo(
                expectedSupply,
                _totalSupply,
                100 + (_totalSupply * 5) / 100
            );
    }

    function echidna_if_eth_balance_is_zero_so_is_total_supply()
        public
        view
        returns (bool)
    {
        return
            (address(this).balance == 0 && totalSupply() == 0) ||
            (address(this).balance >= 0 && totalSupply() >= 0);
    }

    function echidna_if_reserve_is_zero_so_is_total_supply()
        public
        view
        returns (bool)
    {
        return
            (reserveBalance == 0 && totalSupply() == 0) ||
            (reserveBalance >= 0 && totalSupply() >= 0);
    }

    function echidna_user_balance_cannot_exceed_total_supply()
        public
        view
        returns (bool)
    {
        return balanceOf(msg.sender) <= totalSupply();
    }

    /// @dev check if two numbers are close to each other
    /// @param _a first number
    /// @param _b second number
    /// @param _tolerance maximum difference between a and b allowed
    /// @return result true if a and b are close to each other within the tolerance
    function closeTo(
        uint256 _a,
        uint256 _b,
        uint256 _tolerance
    ) internal pure returns (bool) {
        if (_a == _b) return true;
        if (_a > _b) return _a - _b <= _tolerance;
        else return _b - _a <= _tolerance;
    }
}
