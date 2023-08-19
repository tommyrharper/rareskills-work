# Week 7-10

## Week 7

- [x]  [Capture the Ether Guess the secret number](https://github.com/tommyrharper/capture-the-ether-foundry/blob/master/GuessSecretNumber/src/GuessSecretNumber.sol)
- [x]  [Capture the Ether Guess the new number](https://github.com/tommyrharper/capture-the-ether-foundry/blob/master/GuessNewNumber/src/GuessNewNumber.sol)
- [x]  [Capture the Ether predict the future](https://github.com/tommyrharper/capture-the-ether-foundry/blob/master/PredictTheFuture/src/PredictTheFuture.sol)
- [x]  [RareSkills Riddles: ERC1155](https://github.com/tommyrharper/solidity-riddles/blob/main/contracts/attackers/Overmint1_ERC1155_Attacker.sol)
- [x]  [Capture the Ether Token Bank](https://github.com/tommyrharper/capture-the-ether-foundry/blob/master/TokenBank/src/TokenBank.sol)
- [x]  [Capture the Ether Predict the block hash](https://github.com/tommyrharper/capture-the-ether-foundry/blob/master/PredictTheBlockhash/src/PredictTheBlockhash.sol)
- [x]  [Capture the Ether Token Whale Challenge](https://github.com/tommyrharper/capture-the-ether-foundry/blob/master/TokenWhale/src/TokenWhale.sol)


## Week 8

- [x]  [Capture the Ether Token Sale (this one is more challenging)](https://github.com/tommyrharper/capture-the-ether-foundry/blob/master/TokenSale/src/TokenSale.sol)
- [x]  [Capture the Ether Retirement fund](https://github.com/tommyrharper/capture-the-ether-foundry/blob/master/RetirementFund/src/RetirementFund.sol)
- [x]  [Damn Vulnerable Defi #4 Side Entrance (Most vulnerabilities are application specific)](https://github.com/tommyrharper/damn-vulnerable-defi/blob/master/contracts/side-entrance/SideEntranceLenderPool.sol)
- [x]  [Damn Vulnerable Defi #1 Unstoppable (this is challenging)](https://github.com/tommyrharper/damn-vulnerable-defi/blob/master/contracts/unstoppable/UnstoppableVault.sol)
  - [Solution in tests - no attacking contract needed](https://github.com/tommyrharper/damn-vulnerable-defi/blob/master/test/unstoppable/unstoppable.challenge.js)
- [x]  [Ethernaut #20 Denial](./ethernaut-20-denial/src/Denial.sol)
- [ ]  Ethernaut #15 Naught Coin


### Questions

#### Damn Vulnerable Defi #1 Unstoppable

- What is the assembly doing here? It doesn't make much sense to me.
  - [See the code here](https://github.com/tommyrharper/damn-vulnerable-defi/blob/master/contracts/unstoppable/UnstoppableVault.sol)
  - I thought perhaps it is an assembly `nonReentrant` modifier, but storage slot zero seems to refer to `string public name` for the `ERC20` inherited by `ERC4626`.

```solidity
    function totalAssets() public view override returns (uint256) {
        assembly { // better safe than sorry
            if eq(sload(0), 2) {
                mstore(0x00, 0xed3ba6a6)
                revert(0x1c, 0x04)
            }
        }
        return asset.balanceOf(address(this));
    }
```