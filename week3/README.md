# Week 3 & 4

## Uniswap V2 Core

The following changes must be made:
- [x] You must use solidity 0.8.0 or higher, don’t use SafeMath
- [ ] Use an existing fixed point library, but don’t use the Uniswap one.
- [x] Use Openzeppelin’s or Solmate’s safeTransfer instead of building it from scratch like Unisawp does
- [ ] Instead of implementing a flash swap the way Uniswap does, use EIP 3156. **Be very careful at which point you update the reserves!**

Your unit tests should cover the following cases:
- [ ] Adding liquidity
  - [x] With fee off
  - [ ] With fee on
- [ ] Swapping
- [ ] Withdrawing liquidity
- [ ] Taking a flashloan

Corner cases to watch out for:
- [ ] What considerations do you need in your fixed point library? How much of a token with 18 decimals can your contract store?

## Questions

- [x] Why does `kLast` only update if `feeOn` is `true` in the `mint` and `burn` functions?
  - Because it is only used to calculate uniswap protocol fees
