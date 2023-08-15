// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../src/BondingToken.sol";

// import "../node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";

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

    function echidna_test_correct_total_supply() public view returns (bool) {
        return reserveBalance == totalSupply();
    }

    // function test_correct_price() public view returns (bool) {

    // }
}
