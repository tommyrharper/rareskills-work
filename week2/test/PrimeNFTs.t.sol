// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {TestHelpers} from "./TestHelpers.t.sol";
import "../src/primes/PrimeNFTs.sol";
import "../src/primes/PrimeNFTChecker.sol";

contract PrimeNFTsTest is TestHelpers {
    /*//////////////////////////////////////////////////////////////
                                 STATE
    //////////////////////////////////////////////////////////////*/

    PrimeNFTs public prime;
    PrimeNFTChecker public primeChecker;

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
        primeChecker = new PrimeNFTChecker(address(prime));
    }

    /*//////////////////////////////////////////////////////////////
                              BASIC TESTS
    //////////////////////////////////////////////////////////////*/

    function test_isPrime() public {
        assertEq(primeChecker.isPrime(0), false);
        assertEq(primeChecker.isPrime(1), false);
        assertEq(primeChecker.isPrime(2), true);
        assertEq(primeChecker.isPrime(3), true);
        assertEq(primeChecker.isPrime(4), false);
        assertEq(primeChecker.isPrime(5), true);
        assertEq(primeChecker.isPrime(6), false);
        assertEq(primeChecker.isPrime(7), true);
        assertEq(primeChecker.isPrime(8), false);
        assertEq(primeChecker.isPrime(9), false);
        assertEq(primeChecker.isPrime(10), false);
        assertEq(primeChecker.isPrime(11), true);
        assertEq(primeChecker.isPrime(12), false);
        assertEq(primeChecker.isPrime(13), true);
        assertEq(primeChecker.isPrime(14), false);
        assertEq(primeChecker.isPrime(15), false);
        assertEq(primeChecker.isPrime(16), false);
        assertEq(primeChecker.isPrime(17), true);
        assertEq(primeChecker.isPrime(18), false);
        assertEq(primeChecker.isPrime(19), true);
        assertEq(primeChecker.isPrime(20), false);
        assertEq(primeChecker.isPrime(21), false);
        assertEq(primeChecker.isPrime(22), false);
        assertEq(primeChecker.isPrime(23), true);
        assertEq(primeChecker.isPrime(24), false);
        assertEq(primeChecker.isPrime(25), false);
        assertEq(primeChecker.isPrime(26), false);
        assertEq(primeChecker.isPrime(27), false);
        assertEq(primeChecker.isPrime(28), false);
        assertEq(primeChecker.isPrime(29), true);
        assertEq(primeChecker.isPrime(30), false);
    }

    function test_Primes() public {
        prime.mint(address(this), 0);
        prime.mint(address(this), 1);
        prime.mint(address(this), 2);
        prime.mint(address(this), 3);
        prime.mint(address(this), 4);
        prime.mint(address(this), 5);

        assertEq(primeChecker.getNumOfPrimes(address(this)), 3);
    }

    function test_Primes_2() public {
        prime.mint(address(this), 0);
        prime.mint(address(this), 1);
        prime.mint(address(this), 3);
        prime.mint(address(this), 4);
        prime.mint(address(this), 5);

        assertEq(primeChecker.getNumOfPrimes(address(this)), 2);
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

        assertEq(primeChecker.getNumOfPrimes(address(this)), 4);
    }
}
