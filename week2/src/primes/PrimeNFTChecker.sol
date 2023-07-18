// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./PrimeNFTs.sol";
import "openzeppelin/utils/math/Math.sol";

contract PrimeNFTChecker {
    PrimeNFTs public primeNFTs;

    constructor(address _primeNFTs) {
        primeNFTs = PrimeNFTs(_primeNFTs);
    }

    function getNumOfPrimes(address account) external view returns (uint256) {
        unchecked {
            uint256 numPrimes;
            uint256 balance = primeNFTs.balanceOf(account);
            for (uint256 i = 0; i < balance; i++) {
                uint256 tokenId = primeNFTs.tokenOfOwnerByIndex(account, i);
                if (isPrime(tokenId)) {
                    numPrimes++;
                }
            }
            return numPrimes;
        }
    }

    function isPrime(uint256 n) public pure returns (bool) {
        unchecked {
            if (n < 2) return false;
            if (n == 2) return true;
            if (n % 2 == 0) return false;

            uint256 sqrt = Math.sqrt(n);
            for (uint256 i = 3; i <= sqrt; ) {
                if (n % i == 0) {
                    return false;
                }
                i += 2;
            }
            return true;
        }
    }
}
