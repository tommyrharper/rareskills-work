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
        uint256 _totalSupply = totalSupply();

        uint expectedReserves = (_totalSupply ** 2) / 2;

        // add acceptable range/deviance
        uint256 minReserves = (expectedReserves * 90) / 100;
        uint256 maxReserves = ((expectedReserves * 110) / 100) + 10;

        // allow small rounding errors
        if (minReserves > 10) minReserves -= 10;
        else minReserves = 0;

        return reserveBalance <= maxReserves && reserveBalance >= minReserves;
    }

    // function echidna_correct_price() public view returns (bool) {
    //     return reserveBalance / totalSupply() == price;
    // }
}
