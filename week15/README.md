# Week 15

The challenge this week is to gas optimize the following real world contracts:
- [x] [Synthetix Staking Reward](https://github.com/Synthetixio/synthetix/blob/develop/contracts/StakingRewards.sol)
  - [See report here](./staking-rewards.md)
- [ ] [Trader Joe Vesting Contract](https://github.com/traderjoe-xyz/joe-core/blob/main/contracts/TokenVesting.sol)
  - [See my tests here](https://github.com/tommyrharper/joe-core/blob/main/test/TokenVesting.test.ts)
  - [See report here](./vesting-contract.md)
- [ ] [LooksRare Token Distributor](https://github.com/LooksRare/contracts-token-staking/blob/master/contracts/TokenDistributor.sol)
- [ ] [Thirdweb ERC721 Staking](https://github.com/thirdweb-dev/contracts/blob/main/contracts/extension/Staking721.sol)

As reference I will be using [The RareSkills Book of Solidity Gas Optimization: 80+ Tips](https://www.rareskills.io/post/gas-optimization).

To start with I will summarize all the tips in the book in my [Optimization Tips](./optimization-tips.md) document.

## Questions

- [ ] Why does adding a `payable` modifier to the admin functions in the `Trader Joe Vesting Contracting` increase the deployed bytecode size?
