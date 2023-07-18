// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {TestHelpers} from "./TestHelpers.t.sol";
import "../src/primes/PrimeNFTs.sol";

contract PrimeNFTsTest is TestHelpers {
    /*//////////////////////////////////////////////////////////////
                                 STATE
    //////////////////////////////////////////////////////////////*/

    PrimeNFTs public prime;

    address internal user1;
    address internal user2;
    address internal user3;
    address internal user4;
    address internal user5;

    /*//////////////////////////////////////////////////////////////
                                 SETUP
    //////////////////////////////////////////////////////////////*/

    function setUp() public {
        user1 = createAndDealUser(1000 ether);
        user2 = createAndDealUser(1000 ether);
        user3 = createAndDealUser(1000 ether);
        user4 = createAndDealUser(1000 ether);
        user5 = createUser();

        prime = new PrimeNFTs();
    }

    /*//////////////////////////////////////////////////////////////
                              BASIC TESTS
    //////////////////////////////////////////////////////////////*/

    function test_Primes() public {
        prime.mint(address(this), 0);
        prime.mint(address(this), 1);
        prime.mint(address(this), 2);
        prime.mint(address(this), 3);
        prime.mint(address(this), 4);
        prime.mint(address(this), 5);

        assertEq(prime.getNumOfPrimes(address(this)), 3);
    }

    function test_Primes_2() public {
        prime.mint(address(this), 0);
        prime.mint(address(this), 1);
        prime.mint(address(this), 3);
        prime.mint(address(this), 4);
        prime.mint(address(this), 5);

        assertEq(prime.getNumOfPrimes(address(this)), 2);
    }

    function test_Primes_3() public {
        prime.mint(address(this), 0);
        prime.mint(address(this), 1);
        prime.mint(address(this), 3);
        prime.mint(address(this), 4);
        prime.mint(address(this), 5);
        prime.mint(address(this), 6);
        prime.mint(address(this), 7);
        prime.mint(address(this), 8);
        prime.mint(address(this), 9);
        prime.mint(address(this), 11);

        assertEq(prime.getNumOfPrimes(address(this)), 4);
    }
}
