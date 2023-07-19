# Week 2 Work

Due to a crisis at work (vulnerability detected in our smart contracts 😱) I have not had the same amount of time I would usually want to invest into this work.

Hence I have not been as thorough as I would have liked to be.

Luckily we are able to prevent the exploit at work as it was detected internally and we acted quickly, paused the contracts, then I just had to urgently develop the fix, work with auditers at short notice to verify the fix and then deploy it so as to minimize downtime and the community concern.

## Markdown file 1

- Markdown file 1 - [ERC721A.md](./ERC721A.md)

## Markdown file 2

- Markdown file 2 - [WrappedNFTs.md](./WrappedNFTs.md)

## Markdown file 3

- Markdown file 3 - [OpenSeaEvents.md](./OpenSeaEvents.md)

## Smart contract ecosystem 1

- Smart contract ecosystem 1 
  - [RoyaltyNFT.sol](./src/trio/RoyaltyNFT.sol)
  - [NFTRewards.sol](./src/trio/NFTRewards.sol)
  - [RoyaltyNFT.sol](./src/trio/NFTStaking.sol)

### Notes

I setup my contracts up with the following the assumptions:
- Total supply of 20 tokens
- `x < 20` tokens reserved a at a discounted price for users in the merkle tree
  - These cost `1 ether` eachs
- The remaining `20 - x` tokens are sold at a price of `10 ether` each to the public
  - There is no attempt to protect against a public sybil attack
## Smart contract ecosystem 2

- Smart contract ecosystem 2 
  - [PrimeNFTs.sol](./src/primes/PrimeNFTs.sol)
  - [PrimeNFTChecker.sol](./src/primes/PrimeNFTChecker.sol)

### Notes

- I applied the following optimisations to my `isPrime` function
  - Only check division by odd numbers
  - Only check division up to the square root of the number
  - Use unchecked math
- Unapplied optimisations
  - Use a precomputed list of primes
  - Use the Sieve of Eratosthenes
    - (don't know how this works but apparently it is the most efficient algorithm for checking primes)

## CTFs

- CTFs
  - Overmint1 - [Overmint1Attacker.sol](https://github.com/tommyrharper/solidity-riddles/blob/main/contracts/attackers/Overmint1Attacker.sol)
  - Overmint2 - [Overmint1Attacker.sol](https://github.com/tommyrharper/solidity-riddles/blob/main/contracts/attackers/Overmint2Attacker.sol)
