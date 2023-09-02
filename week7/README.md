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
  - [Link to instructions](https://ethernaut.openzeppelin.com/level/20)
- [x]  [Ethernaut #15 Naught Coin](./ethernaut-15-naught-coin/src/NaughtCoin.sol)
  - [Solution in tests - no attacking contract needed](./ethernaut-15-naught-coin/test/NaughtCoin.t.sol)
  - [Link to instructions](https://ethernaut.openzeppelin.com/level/15)

## Week 9

- [x]  [RareSkills Riddles: Forwarder (abi encoding)](https://github.com/tommyrharper/solidity-riddles/blob/main/contracts/Forwarder.sol)
  - [Solution in tests - no attacking contract needed](https://github.com/tommyrharper/solidity-riddles/blob/main/test/Forwarder.js)
- [x]  [Damn Vulnerable Defi #3 Truster (this is challenging)](https://github.com/tommyrharper/damn-vulnerable-defi/blob/master/contracts/truster/TrusterLenderPool.sol)
  - [Solution in tests - no attacking contract needed](https://github.com/tommyrharper/damn-vulnerable-defi/blob/master/test/truster/truster.challenge.js)
- [x]  [RareSkills Riddles: Overmint3 (Double voting or msg.sender spoofing)](https://github.com/tommyrharper/solidity-riddles/blob/main/contracts/Overmint3.sol)
  - [Solution in tests - no attacking contract needed](https://github.com/tommyrharper/solidity-riddles/blob/main/test/Overmint3.js)
- [x]  [RareSkills Riddles: Democracy (Double voting or msg.sender spoofing)](https://github.com/tommyrharper/solidity-riddles/blob/main/contracts/Democracy.sol)
- [x]  [Ethernaut #13 Gatekeeper 1](./ethernaut-13-gatekeeper/src/GatekeeperOne.sol)

## Week 10

- [x]  [RareSkills Riddles: Delete user (understanding storage pointers)](https://github.com/tommyrharper/solidity-riddles/blob/main/contracts/DeleteUser.sol)
- [x]  [RareSkills Riddles: Viceroy (understanding the delete keyword)](https://github.com/tommyrharper/solidity-riddles/blob/main/contracts/Viceroy.sol)
- [x]  [Ethernaut #23 Dex2 (access control / input validation)](./ethernaut-23-dex2/src/DexTwo.sol)
  - [Solution in tests](./ethernaut-23-dex2/test/DexTwo.t.sol)
- [x]  [Damn Vulnerable DeFi #2 Naive Receiver (access control / input validation)](https://github.com/tommyrharper/damn-vulnerable-defi/blob/master/contracts/naive-receiver/NaiveReceiverLenderPool.sol)
- [x]  [RareSkills Riddles: RewardToken (cross function reentrancy)](https://github.com/tommyrharper/solidity-riddles/blob/main/contracts/RewardToken.sol)
- [x]  [RareSkills Riddles: Read-only reentrancy (read-only reentrancy)](https://github.com/tommyrharper/solidity-riddles/blob/main/contracts/ReadOnly.sol)
- [ ]  Damn Vulnerable DeFi #5 (flash loan attack)
- [ ]  Damn Vulnerable DeFi #6 (flash loan attack)

## Questions

### Damn Vulnerable Defi #1 Unstoppable

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

### RareSkills Riddles: Overmint3 (Double voting or msg.sender spoofing)

- Is this really what I was supposed to do (just buy from a bunch of addresses and transfer)? Seems to easy.
  - There is reentrancy if the `require(!msg.sender.isContract(), "no contracts");` check can be bypassed, is this possible? - I tried using the constructor, but then `IERC721Receiver` couldn't be invoked.
  - [See the code here](https://github.com/tommyrharper/solidity-riddles/blob/main/test/Overmint3.js)

### RareSkills Riddles: Democracy (Double voting or msg.sender spoofing)

- Not sure if I over complicated this one:
  - I had a contract that produces replicas of itself in the `receive` function
  - [See the code here](https://github.com/tommyrharper/solidity-riddles/blob/main/contracts/Democracy.sol)
  - Also why doesn't `await victimContract.connect(attackerWallet).safeTransferFrom(attackerWallet.address, attackerContract.address, 0);` in [the tests](https://github.com/tommyrharper/solidity-riddles/blob/main/test/Democracy.js).

### Ethernaut #13 Gatekeeper 1

- In terms of the gas calculation I used some trial and error
  - How would I calculate it precisely?
  - [See the code here](./ethernaut-13-gatekeeper/src/GatekeeperOne.sol)
