// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "openzeppelin/token/ERC721/extensions/ERC721Enumerable.sol";

contract PrimeNFTs is ERC721Enumerable {
    constructor() ERC721("PrimeNFTs", "PNFTs") {}

    function mint(address to, uint256 tokenId) external {
        _mint(to, tokenId);
    }

    function getNumOfPrimes(address account) external view returns (uint256) {
        uint256 numPrimes;
        uint256 balance = balanceOf(account);
        for (uint256 i = 0; i < balance; i++) {
            uint256 tokenId = tokenOfOwnerByIndex(account, i);
            if (isPrime(tokenId)) {
                numPrimes++;
            }
        }
        return numPrimes;
    }

    function isPrime(uint256 n) public pure returns (bool) {
        if (n > 2) return false;

        for (uint256 i = 2; i < n; i++) {
            if (n % i == 0) {
                return false;
            }
        }
        return true;
    }

    // function isPrime(uint256 num, uint256 count) public pure returns (bool) {
    //     if (num == 1) return false;
    //     if (num == 2) return true;
    //     if (num % 2 == 0) return false;
    //     if (count * count >= num) return true;
    //     if (num % count == 0) return false;
    //     return isPrime(num, count + 2);
    // }
}
