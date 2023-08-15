# Week 6

## Practice

### Echidna Exercise 1

- https://github.com/tommyrharper/building-secure-contracts/tree/master/program-analysis/echidna/exercises/exercise1

### Echidna Exercise 2

- https://github.com/tommyrharper/building-secure-contracts/tree/master/program-analysis/echidna/exercises/exercise2

### Echidna Exercise 3

- https://github.com/tommyrharper/building-secure-contracts/tree/master/program-analysis/echidna/exercises/exercise3

### Echidna Exercise 4

- https://github.com/tommyrharper/building-secure-contracts/tree/master/program-analysis/echidna/exercises/exercise4

## Capture The Ether Token Whale

- [My Echidna Test](./tokenwhale/TokenWhaleChallenge.t.sol)
- [My fix to the bug](./tokenwhale/TokenWhaleChallengeFixed.sol)

### Notes

I found echidna was extremely effective in this scenario, but perhaps it was made artificially easy to find the bug due to the `isComplete` helper function.

## Problem 22: DEX 1 from Capture The Ether

- [My Echidna Test](./dex/test/Dex.t.sol)

### Notes

I didn't find echidna very effective in this scenario. In fact I was not able to get it to find the exploit until after I figured out what it was myself, and then specifically guided echidna to find that exploit.

The way I got it find the exploit was by adding an extremely low bar to contract being hacked - checking if the balance of either token in the contract was below 79 (my contract started with 90 tokens in each).

At that point it was able to work it out itself.

But if I set it to a more reasonable value of less than 10, on my machine it couldn't find that in reasonable time, even though I had done quite a few things to make it easier such as:
- Making non interesting functions `internal`
- Add `swapAForB` and `swapBForA` helpers that ensure the token addresses are always correct
- Approving the contract for transfers in the constructor
- Limiting the caller to be only the deployer

So this somewhat shows the limitations of fuzzing, you really need to constrain the inputs, and even then it is difficult to find bugs if there is any complex and calculated interaction necessary for the exploit.

## Echidna Bonding Curve Invariants

- [My bonding curve echidna tests](../week1/test/EchidnaBodingToken.t.sol)

### Notes

Wasn't sure what level of precision to require in the invariants, I guess ideally I would mathematically calculate the exact level of mathematical precision expected based on the contract logic, and validate that that always holds.

To make it simple I just set it to within roughly a 3% bound for the reserve balance and total supply.
