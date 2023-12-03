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
