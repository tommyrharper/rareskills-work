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


## To Add

- Using unsafeAccess on arrays to avoid redundant length checks
  - see constructor
- revert with assembly
- do while loop