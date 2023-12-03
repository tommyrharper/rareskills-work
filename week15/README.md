# Week 15

The challenge this week is to gas optimize the following real world contracts:
- [x] [Synthetix Staking Reward](https://github.com/Synthetixio/synthetix/blob/develop/contracts/StakingRewards.sol)
  - [See tests here](https://github.com/Synthetixio/synthetix/blob/develop/test/contracts/StakingRewards.js) - not my own.
  - [See report here](./staking-rewards.md)
- [x] [Trader Joe Vesting Contract](https://github.com/traderjoe-xyz/joe-core/blob/main/contracts/TokenVesting.sol)
  - [See my tests here](https://github.com/tommyrharper/joe-core/blob/main/test/TokenVesting.test.ts) - I wrote these.
  - [See report here](./vesting-contract.md)
- [x] [LooksRare Token Distributor](https://github.com/LooksRare/contracts-token-staking/blob/master/contracts/TokenDistributor.sol)
  - [See tests here](https://github.com/LooksRare/contracts-token-staking/blob/master/test/tokenDistributor.test.ts) - not my own.
  - [See report here](./token-distributor.md)
- [ ] [Thirdweb ERC721 Staking](https://github.com/thirdweb-dev/contracts/blob/main/contracts/extension/Staking721.sol)
  - [See tests here](https://github.com/thirdweb-dev/contracts/blob/main/src/test/sdk/extension/StakingExtension.t.sol) - not my own.
  - [See report here](./erc721-staking.md)

As reference I will be using [The RareSkills Book of Solidity Gas Optimization: 80+ Tips](https://www.rareskills.io/post/gas-optimization).

To start with I will summarize all the tips in the book in my [Optimization Tips](./optimization-tips.md) document.

## Notes

For this challenge I didn't do a full and comprehensive optimization. Instead I time-boxed my investigation of each contract and started with looking at the largest optimizations - mostly storage related. Then following that I looked into different optimizations that I predominantly had not done in the other contracts, to cover a wide array of optimizations.

## Questions

- [ ] In the Rareskills Gas Optimisation book it says under `Design Patterns` - `4. Consider packing calldata, especially on an L2`. Why especially on an L2? I would have thought this would be more important on L1 where gas costs are higher.
- [ ] Why does adding a `payable` modifier to the admin functions in the `Trader Joe Vesting Contracting` increase the deployed bytecode size?
- [ ] When I tested doing a string revert with assembly in the looks rare `token-distributor` (`[G-07]`), I got the following error (not sure why)
  - ` AssertionError: Expected transaction to be reverted with Deposit: Amount must be > 0, but other exception was thrown: Error: VM Exception while processing transaction: reverted with an unrecognized custom error`
  - Why is this happening?
This was the code change:
Before:
```solidity
    function deposit(uint256 amount) external nonReentrant {
        require(amount > 0, "Deposit: Amount must be > 0");
        ...
```

After:
```solidity
    function deposit(uint256 amount) external nonReentrant {
        assembly {
            if iszero(amount) {
                mstore(0x00, 0x20) // store offset to where length of revert message is stored
                mstore(0x20, 0x1b) // store length (27)
                mstore(0x40, 0x4465706f7369743a20416d6f756e74206d757374206265203e20300000000000) // store hex representation of message
                revert(0x00, 0x60) // revert with data
            }
        }
        ...
```

This is the test:
```typescript
    it.only("Cannot deposit if amount is 0", async () => {
      await expect(tokenDistributor.connect(user1).deposit("0")).to.be.revertedWith("Deposit: Amount must be > 0");
    });
```

## Gas optimizations done by:

//   $$\
//   $$ | 
// $$$$$$\    $$$$$$\  $$$$$$\$$$$\
// \_$$  _|  $$ |  $$\ $$ | $$ | $$\
//   $$ |    $$ |  $$ |$$ | $$ | $$ |
//   $$ |$$\ $$ |  $$ |$$ | $$ | $$ |
//   \$$$$  | $$$$$$ / $$ | $$ | $$ |
//    \____/ \______/  \__/ \__/ \__/
