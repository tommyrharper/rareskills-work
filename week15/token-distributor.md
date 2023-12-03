# LooksRare Token Distributor Gas Optimizations

Note - I didn't write my own tests for this, I just reused the ones in the `LooksRare/contracts-token-staking` repo, and turned the `gas-reporter` on.


[See here for the full tests](https://github.com/LooksRare/contracts-token-staking/blob/master/test/tokenDistributor.test.ts).

## Gas usage without optimizations

```
·-------------------------------------------|---------------------------|----------------|-----------------------------·
|           Solc version: 0.8.19            ·  Optimizer enabled: true  ·  Runs: 888888  ·  Block limit: 30000000 gas  │
············································|···························|················|······························
|  Methods                                  ·                26 gwei/gas                 ·       1980.49 eur/eth       │
·····················|······················|·············|·············|················|···············|··············
|  Contract          ·  Method              ·  Min        ·  Max        ·  Avg           ·  # calls      ·  eur (avg)  │
·····················|······················|·············|·············|················|···············|··············
|  TokenDistributor  ·  deposit             ·      67778  ·     121574  ·         93023  ·           56  ·       4.79  │
·····················|······················|·············|·············|················|···············|··············
|  TokenDistributor  ·  harvestAndCompound  ·      32446  ·     136948  ·         97881  ·           12  ·       5.04  │
·····················|······················|·············|·············|················|···············|··············
|  TokenDistributor  ·  updatePool          ·      69804  ·     104004  ·         86904  ·            4  ·       4.47  │
·····················|······················|·············|·············|················|···············|··············
|  TokenDistributor  ·  withdraw            ·      45218  ·     148043  ·         79316  ·           10  ·       4.08  │
·····················|······················|·············|·············|················|···············|··············
|  TokenDistributor  ·  withdrawAll         ·      31194  ·     152831  ·         80861  ·           19  ·       4.16  │
·····················|······················|·············|·············|················|···············|··············
|  Deployments                              ·                                            ·  % of limit   ·             │
············································|·············|·············|················|···············|··············
|  TokenDistributor                         ·    1784073  ·    1784097  ·       1784084  ·        5.9 %  ·      91.87  │
·-------------------------------------------|-------------|-------------|----------------|---------------|-------------·
```

## [G-01] Pack related variables

A series of variables store block numbers which can fit into a single slot.

Before:
```solidity
    // Current phase for rewards
    uint256 public currentPhase;

    // Block number when rewards end
    uint256 public endBlock;

    // Block number of the last update
    uint256 public lastRewardBlock;
```

After:
```solidity
    // Current phase for rewards
    uint80 public currentPhase;

    // Block number when rewards end
    uint80 public endBlock;

    // Block number of the last update
    uint80 public lastRewardBlock;
```

The results:

```
Before:
|  TokenDistributor  ·  harvestAndCompound  ·      32446  ·     136948  ·         97881  ·           12  ·       5.04  │
·····················|······················|·············|·············|················|···············|··············
|  TokenDistributor  ·  updatePool          ·      69804  ·     104004  ·         86904  ·            4  ·       4.47  │
·····················|······················|·············|·············|················|···············|··············
|  TokenDistributor  ·  withdraw            ·      45218  ·     148043  ·         79316  ·           10  ·       4.08  │
·····················|······················|·············|·············|················|···············|··············
|  TokenDistributor  ·  withdrawAll         ·      31194  ·     152831  ·         80861  ·           19  ·       4.16  │

After:
|  TokenDistributor  ·  harvestAndCompound  ·      32463  ·     135088  ·         92436  ·           12  ·       5.31  │
·····················|······················|·············|·············|················|···············|··············
|  TokenDistributor  ·  updatePool          ·      67944  ·     102144  ·         85044  ·            4  ·       4.88  │
·····················|······················|·············|·············|················|···············|··············
|  TokenDistributor  ·  withdraw            ·      45235  ·     139475  ·         77240  ·           10  ·       4.43  │
·····················|······················|·············|·············|················|···············|··············
|  TokenDistributor  ·  withdrawAll         ·      31202  ·     126717  ·         71706  ·           19  ·       4.12  │
```

Change:
- harvestAndCompound: `97881 - 92436 = 5445` gas saved
- updatePool: `86904 - 85044 = 1860` gas saved
- withdraw: `79316 - 77240 = 2076` gas saved
- withdrawAll: `80861 - 71706 = 9155` gas saved

## [G-02] Pack structs

There are a number of structs we can pack, based on our knowledge of the limited range of values they can take.

We know the maximum total supply of `LOOKS` tokens is 1 billion. We can pack the `uint256` into a `uint112` to save gas.

And the other is a block length.

Before:
```solidity
    struct StakingPeriod {
        uint256 rewardPerBlockForStaking;
        uint256 rewardPerBlockForOthers;
        uint256 periodLengthInBlock;
    }

    struct UserInfo {
        uint256 amount; // Amount of staked tokens provided by user
        uint256 rewardDebt; // Reward debt
    }
```

After:
```solidity
    struct StakingPeriod {
        uint112 rewardPerBlockForStaking;
        uint112 rewardPerBlockForOthers;
        uint32 periodLengthInBlock;
    }

    struct UserInfo {
        uint128 amount; // Amount of staked tokens provided by user
        uint128 rewardDebt; // Reward debt
    }
```

```
Before:
|  TokenDistributor  ·  deposit             ·      67778  ·     121574  ·         93023  ·           56  ·       4.79  │
·····················|······················|·············|·············|················|···············|··············
|  TokenDistributor  ·  harvestAndCompound  ·      32446  ·     136948  ·         97881  ·           12  ·       5.04  │
·····················|······················|·············|·············|················|···············|··············
|  TokenDistributor  ·  withdraw            ·      45218  ·     148043  ·         79316  ·           10  ·       4.08  │
·····················|······················|·············|·············|················|···············|··············
|  TokenDistributor  ·  withdrawAll         ·      31194  ·     152831  ·         80861  ·           19  ·       4.16  │
After:
|  TokenDistributor  ·  deposit             ·      66025  ·     119813  ·         91262  ·           56  ·       5.44  │
·····················|······················|·············|·············|················|···············|··············
|  TokenDistributor  ·  harvestAndCompound  ·      30354  ·     115268  ·         88880  ·           12  ·       5.29  │
·····················|······················|·············|·············|················|···············|··············
|  TokenDistributor  ·  withdraw            ·      43406  ·     118387  ·         67955  ·           10  ·       4.05  │
·····················|······················|·············|·············|················|···············|··············
|  TokenDistributor  ·  withdrawAll         ·      30105  ·     146682  ·         79037  ·           19  ·       4.71  │
```

Change:
- deposit: `93023 - 91262 = 1761` gas saved
- harvestAndCompound: `97881 - 88880 = 9001` gas saved
- withdraw: `79316 - 67955 = 11361` gas saved
- withdrawAll: `80861 - 79037 = 1824` gas saved


## [G-03] Cache variables read from array multiple times

Before:
```solidity
        for (uint256 i = 0; i < _numberPeriods; i++) {
            amountTokensToBeMinted +=
                (_rewardsPerBlockForStaking[i] * _periodLengthesInBlocks[i]) +
                (_rewardsPerBlockForOthers[i] * _periodLengthesInBlocks[i]);

            stakingPeriod[i] = StakingPeriod({
                rewardPerBlockForStaking: _rewardsPerBlockForStaking[i],
                rewardPerBlockForOthers: _rewardsPerBlockForOthers[i],
                periodLengthInBlock: _periodLengthesInBlocks[i]
            });
        }
```

After:
```solidity
        for (uint256 i = 0; i < _numberPeriods; i++) {
            uint256 rewardsPerBlockForStaking = _rewardsPerBlockForStaking[i];
            uint256 rewardsPerBlockForOthers = _rewardsPerBlockForOthers[i];
            uint256 periodLengthInBlock = _periodLengthesInBlocks[i];

            amountTokensToBeMinted +=
                (rewardsPerBlockForStaking * periodLengthInBlock) +
                (rewardsPerBlockForOthers * periodLengthInBlock);

            stakingPeriod[i] = StakingPeriod({
                rewardPerBlockForStaking: rewardsPerBlockForStaking,
                rewardPerBlockForOthers: rewardsPerBlockForOthers,
                periodLengthInBlock: periodLengthInBlock
            });
        }
```

```
Before:
|  Deployments                              ·                                            ·  % of limit   ·             │
············································|·············|·············|················|···············|··············
|  TokenDistributor                         ·    1784073  ·    1784097  ·       1784084  ·        5.9 %  ·      91.87  │

After:
|  Deployments                              ·                                            ·  % of limit   ·             │
············································|·············|·············|················|···············|··············
|  TokenDistributor                         ·    1781661  ·    1781685  ·       1781672  ·        5.9 %  ·     109.69  │
```

Change:
- deployment: `1784084 - 1781672 = 2412` gas saved

## [G-04] Using assembly when accessing arrays to avoid redundant length checks

In the loop mentioned in [G-03] we can use unsafe access to avoid the redundant length checks.

This is because we have already done the following check earlier:

```solidity
        require(
            (_periodLengthesInBlocks.length == _numberPeriods) &&
                (_rewardsPerBlockForStaking.length == _numberPeriods) &&
                (_rewardsPerBlockForStaking.length == _numberPeriods),
            "Distributor: Lengthes must match numberPeriods"
        );
```

So lets build on top of the previous optimization:

Now:
```solidity
        for (uint256 i = 0; i < _numberPeriods; i++) {
            uint256 rewardsPerBlockForStaking;
            uint256 rewardsPerBlockForOthers;
            uint256 periodLengthInBlock;
            assembly {
                rewardsPerBlockForStaking := mload(add(_rewardsPerBlockForStaking, add(0x20, mul(i, 0x20))))
                rewardsPerBlockForOthers := mload(add(_rewardsPerBlockForOthers, add(0x20, mul(i, 0x20))))
                periodLengthInBlock := mload(add(_periodLengthesInBlocks, add(0x20, mul(i, 0x20))))
            }

            amountTokensToBeMinted +=
                (rewardsPerBlockForStaking * periodLengthInBlock) +
                (rewardsPerBlockForOthers * periodLengthInBlock);

            stakingPeriod[i] = StakingPeriod({
                rewardPerBlockForStaking: rewardsPerBlockForStaking,
                rewardPerBlockForOthers: rewardsPerBlockForOthers,
                periodLengthInBlock: periodLengthInBlock
            });
        }

```

```
Before:
|  TokenDistributor                         ·    1781661  ·    1781685  ·       1781672  ·        5.9 %  ·     109.69  │
After:
|  TokenDistributor                         ·    1780113  ·    1780137  ·       1780124  ·        5.9 %  ·     116.56  │
```

Change:
- deployment: `1781672 - 1780124 = 1548` gas saved

## [G-05] Write gas-optimal for-loops

We can further optimise this same bit of code mentioned in `[G-03]` and `[G-04]` by applying common loop optimizations.

Now
```solidity
        for (uint256 i = 0; i < _numberPeriods; ) {
            uint256 rewardsPerBlockForStaking;
            uint256 rewardsPerBlockForOthers;
            uint256 periodLengthInBlock;
            assembly {
                rewardsPerBlockForStaking := mload(add(_rewardsPerBlockForStaking, add(0x20, mul(i, 0x20))))
                rewardsPerBlockForOthers := mload(add(_rewardsPerBlockForOthers, add(0x20, mul(i, 0x20))))
                periodLengthInBlock := mload(add(_periodLengthesInBlocks, add(0x20, mul(i, 0x20))))
            }

            amountTokensToBeMinted +=
                (rewardsPerBlockForStaking * periodLengthInBlock) +
                (rewardsPerBlockForOthers * periodLengthInBlock);

            stakingPeriod[i] = StakingPeriod({
                rewardPerBlockForStaking: rewardsPerBlockForStaking,
                rewardPerBlockForOthers: rewardsPerBlockForOthers,
                periodLengthInBlock: periodLengthInBlock
            });

            unchecked {
                ++i;
            }
        }
```

```
Before:
|  TokenDistributor                         ·    1780113  ·    1780137  ·       1780124  ·        5.9 %  ·     116.56  │
After:
|  TokenDistributor                         ·    1779369  ·    1779393  ·       1779380  ·        5.9 %  ·     134.37  │
```

Change:
- deployment: `1780124 - 1779380 = 744` gas saved

## [G-06] Do-While loops are cheaper than for loops

We can take this one step further yet, using a do-while loop instead of a for-loop.

Now:
```solidity
        do {
            uint256 rewardsPerBlockForStaking;
            uint256 rewardsPerBlockForOthers;
            uint256 periodLengthInBlock;
            assembly {
                rewardsPerBlockForStaking := mload(add(_rewardsPerBlockForStaking, add(0x20, mul(i, 0x20))))
                rewardsPerBlockForOthers := mload(add(_rewardsPerBlockForOthers, add(0x20, mul(i, 0x20))))
                periodLengthInBlock := mload(add(_periodLengthesInBlocks, add(0x20, mul(i, 0x20))))
            }

            amountTokensToBeMinted +=
                (rewardsPerBlockForStaking * periodLengthInBlock) +
                (rewardsPerBlockForOthers * periodLengthInBlock);

            stakingPeriod[i] = StakingPeriod({
                rewardPerBlockForStaking: rewardsPerBlockForStaking,
                rewardPerBlockForOthers: rewardsPerBlockForOthers,
                periodLengthInBlock: periodLengthInBlock
            });

            unchecked {
                ++i;
            }
        } while (i < _numberPeriods);
```


```
Before:
|  TokenDistributor                         ·    1779369  ·    1779393  ·       1779380  ·        5.9 %  ·     134.37  │
After:
|  TokenDistributor                         ·    1779186  ·    1779210  ·       1779197  ·        5.9 %  ·     120.10  │
```

Change:
- deployment: `1779380 - 1779197 = 183` gas saved

Total savings with all the optimizations to this piece of code:
- deployment: `1784084 - 1779197 = 4887` gas saved

## [G-07] Using assembly to revert with an error message

For this one we will use a specific test:
```ts
    it.only("Cannot deposit if amount is 0", async () => {
      await expect(tokenDistributor.connect(user1).deposit("0")).to.be.reverted;
    });
```

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
```
Before:
|  Contract          ·  Method   ·  Min        ·  Max        ·  Avg           ·  # calls      ·  eur (avg)  │
·····················|···········|·············|·············|················|···············|··············
|  TokenDistributor  ·  deposit  ·      84346  ·     118546  ·         92896  ·            4  ·       5.52  │
·····················|···········|·············|·············|················|···············|··············
|  Deployments                   ·                                            ·  % of limit   ·             │
·································|·············|·············|················|···············|··············
|  TokenDistributor              ·          -  ·          -  ·       1784073  ·        5.9 %  ·     105.92  │

After:
|  Contract          ·  Method   ·  Min        ·  Max        ·  Avg           ·  # calls      ·  eur (avg)  │
·····················|···········|·············|·············|················|···············|··············
|  TokenDistributor  ·  deposit  ·      84346  ·     118546  ·         92896  ·            4  ·       6.25  │
·····················|···········|·············|·············|················|···············|··············
|  Deployments                   ·                                            ·  % of limit   ·             │
·································|·············|·············|················|···············|··············
|  TokenDistributor              ·          -  ·          -  ·       1774442  ·        5.9 %  ·     119.38  │
```

Interestingly the outcome of this is not as expected. The runtime gas cost is actually the same in both scenarios, however there was a decrease in the deployment cost, which is interesting:

Change:
- deployment: `1784073 - 1774442 = 9631` gas saved
- runtime: `92896 - 92896 = 0` gas saved

## [G-08] Use ++i instead of i++ to increment

Before:
```solidity
    function _updateRewardsPerBlock(uint256 _newStartBlock) internal {
        // Update current phase
        currentPhase++;

        // Update rewards per block
        rewardPerBlockForStaking = stakingPeriod[currentPhase].rewardPerBlockForStaking;
        rewardPerBlockForOthers = stakingPeriod[currentPhase].rewardPerBlockForOthers;

        emit NewRewardsPerBlock(currentPhase, _newStartBlock, rewardPerBlockForStaking, rewardPerBlockForOthers);
    }
```

After:
```solidity
    function _updateRewardsPerBlock(uint256 _newStartBlock) internal {
        // Update current phase
        ++currentPhase;

        // Update rewards per block
        rewardPerBlockForStaking = stakingPeriod[currentPhase].rewardPerBlockForStaking;
        rewardPerBlockForOthers = stakingPeriod[currentPhase].rewardPerBlockForOthers;

        emit NewRewardsPerBlock(currentPhase, _newStartBlock, rewardPerBlockForStaking, rewardPerBlockForOthers);
    }
```

```
Before:
|  Contract          ·  Method              ·  Min        ·  Max        ·  Avg           ·  # calls      ·  eur (avg)  │
·····················|······················|·············|·············|················|···············|··············
|  TokenDistributor  ·  harvestAndCompound  ·      32446  ·     136948  ·         97881  ·           12  ·       5.04  │
·····················|······················|·············|·············|················|···············|··············
|  TokenDistributor  ·  withdraw            ·      45218  ·     148043  ·         79316  ·           10  ·       4.08  │
·····················|······················|·············|·············|················|···············|··············
|  TokenDistributor  ·  withdrawAll         ·      31194  ·     152831  ·         80861  ·           19  ·       4.16  │
·····················|······················|·············|·············|················|···············|··············
|  Deployments                              ·                                            ·  % of limit   ·             │
············································|·············|·············|················|···············|··············
|  TokenDistributor                         ·    1784073  ·    1784097  ·       1784084  ·        5.9 %  ·      91.87  │

After:
|  Contract          ·  Method              ·  Min        ·  Max        ·  Avg           ·  # calls      ·  eur (avg)  │
·····················|······················|·············|·············|················|···············|··············
|  TokenDistributor  ·  harvestAndCompound  ·      32446  ·     136948  ·         97879  ·           12  ·       6.21  │
·····················|······················|·············|·············|················|···············|··············
|  TokenDistributor  ·  withdraw            ·      45218  ·     148033  ·         79314  ·           10  ·       5.03  │
·····················|······················|·············|·············|················|···············|··············
|  TokenDistributor  ·  withdrawAll         ·      31194  ·     152826  ·         80859  ·           19  ·       5.13  │
·····················|······················|·············|·············|················|···············|··············
|  Deployments                              ·                                            ·  % of limit   ·             │
············································|·············|·············|················|···············|··············
|  TokenDistributor                         ·    1783653  ·    1783677  ·       1783664  ·        5.9 %  ·     113.10  │
```

Change:
- harvestAndCompound: `97881 - 97879 = 2` gas saved
- withdraw: `79316 - 79314 = 2` gas saved
- withdrawAll: `80861 - 80859 = 2` gas saved
- deployment: `1784084 - 1783664 = 420` gas saved
