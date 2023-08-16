# Week 3 & 4

## Uniswap V2 Core

The following changes must be made:
- [x] You must use solidity 0.8.0 or higher, don’t use SafeMath
- [ ] Use an existing fixed point library, but don’t use the Uniswap one.
- [x] Use Openzeppelin’s or Solmate’s safeTransfer instead of building it from scratch like Unisawp does
- [x] Instead of implementing a flash swap the way Uniswap does, use EIP 3156. **Be very careful at which point you update the reserves!**

Your unit tests should cover the following cases:
- [x] Adding liquidity
  - [x] First mint
  - [x] Second mint
- [x] Swapping
- [x] Withdrawing liquidity
- [x] Taking a flashloan

Corner cases to watch out for:
- [x] What considerations do you need in your fixed point library? How much of a token with 18 decimals can your contract store?

## Max Deposit

- Max value of reserve0 or reserve1 in regards to the FixedPoint arithmetic is `(2^256 - 1) / (2^32 - 1) / 10^18 = 26959946673427741531515197488526605382048662297355` or `type(uint256).max / type(uint32).max / 1e18`
  - This is due to the fact that:
    - My fixed point numbers are `uint256`
    - I multiple by the timeElapsed before dividing (which is a `uint32`)
    - My fixed point numbers are scaled by `10^18`
- As my fixed point numbers are `uint256`, but my reserve values are `uint112` in storage, the fixed point arithmetic is not the limiting factor for overflows, the limiting factor is the integer reserve value itself, as `2^112 - 1 < (2^256 - 1) / (2^32 - 1) / 10^18` or `type(uint256).max / type(uint32).max / 1e18 > type(uint112).max`
## Questions

- [x] Why does `kLast` only update if `feeOn` is `true` in the `mint` and `burn` functions?
  - Because it is only used to calculate uniswap protocol fees
99999999999999999999999999999999999999
10000000000000000000000000000000000000