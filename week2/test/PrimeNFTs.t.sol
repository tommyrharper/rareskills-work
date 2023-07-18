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

    function test_isPrime() public {
        assertEq(prime.isPrime(0), false);
        assertEq(prime.isPrime(1), false);
        assertEq(prime.isPrime(2), true);
        assertEq(prime.isPrime(3), true);
        assertEq(prime.isPrime(4), false);
        assertEq(prime.isPrime(5), true);
        assertEq(prime.isPrime(6), false);
        assertEq(prime.isPrime(7), true);
        assertEq(prime.isPrime(8), false);
        assertEq(prime.isPrime(9), false);
        assertEq(prime.isPrime(10), false);
        assertEq(prime.isPrime(11), true);
        assertEq(prime.isPrime(12), false);
        assertEq(prime.isPrime(13), true);
        assertEq(prime.isPrime(14), false);
        assertEq(prime.isPrime(15), false);
        assertEq(prime.isPrime(16), false);
        assertEq(prime.isPrime(17), true);
        assertEq(prime.isPrime(18), false);
        assertEq(prime.isPrime(19), true);
        assertEq(prime.isPrime(20), false);
        assertEq(prime.isPrime(21), false);
        assertEq(prime.isPrime(22), false);
        assertEq(prime.isPrime(23), true);
        assertEq(prime.isPrime(24), false);
        assertEq(prime.isPrime(25), false);
        assertEq(prime.isPrime(26), false);
        assertEq(prime.isPrime(27), false);
        assertEq(prime.isPrime(28), false);
        assertEq(prime.isPrime(29), true);
        assertEq(prime.isPrime(30), false);
    }

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
