# Third Web Staking721 Gas Optimizations

Note - I didn't write my own tests for this, I just reused the ones in the `thirdweb` repo, and turned the `gas-reporter` on.

[See here for the full tests](https://github.com/thirdweb-dev/contracts/blob/main/src/test/sdk/extension/StakingExtension.t.so).

## Gas usage without optimizations


| Deployment Cost                                                          | Deployment Size |        |        |        |         |
|--------------------------------------------------------------------------|-----------------|--------|--------|--------|---------|
| 1977635                                                                  | 10620           |        |        |        |         |
| Function Name                                                            | min             | avg    | median | max    | # calls |
| balanceOf                                                                | 826             | 826    | 826    | 826    | 1       |
| claimRewards                                                             | 5895            | 31874  | 29827  | 61949  | 4       |
| getRewardsPerUnitTime                                                    | 769             | 2102   | 769    | 4769   | 3       |
| getStakeInfo                                                             | 7228            | 10615  | 9444   | 17956  | 13      |
| getTimeUnit                                                              | 1275            | 2608   | 1275   | 5275   | 3       |
| onERC721Received                                                         | 974             | 974    | 974    | 974    | 23      |
| setCondition                                                             | 4490            | 4490   | 4490   | 4490   | 2       |
| setRewardsPerUnitTime                                                    | 632             | 65416  | 92408  | 103208 | 3       |
| setTimeUnit                                                              | 742             | 65530  | 92524  | 103324 | 3       |
| stake                                                                    | 5690            | 264347 | 353748 | 355748 | 11      |
| stakerAddress                                                            | 873             | 873    | 873    | 873    | 10      |
| withdraw                                                                 | 4316            | 23533  | 20940  | 49415  | 5       |


## [G-01] Variables that are never updated should be immutable or constant

Before:
```solidity
    address public stakingToken;
```

After:
```solidity
    address public immutable stakingToken;
```

Before:
| Function Name                                                            | min             | avg    | median | max    | # calls |
|--------------------------------------------------------------------------|-----------------|--------|--------|--------|---------|
| claimRewards                                                             | 5895            | 31874  | 29827  | 61949  | 4       |
| getStakeInfo                                                             | 7228            | 10615  | 9444   | 17956  | 13      |
| onERC721Received                                                         | 974             | 974    | 974    | 974    | 23      |
| setRewardsPerUnitTime                                                    | 632             | 65416  | 92408  | 103208 | 3       |
| setTimeUnit                                                              | 742             | 65530  | 92524  | 103324 | 3       |
| stake                                                                    | 5690            | 264347 | 353748 | 355748 | 11      |
| withdraw                                                                 | 4316            | 23533  | 20940  | 49415  | 5       |

After:
| Function Name                                                            | min             | avg    | median | max    | # calls |
|--------------------------------------------------------------------------|-----------------|--------|--------|--------|---------|
| claimRewards                                                             | 5889            | 31866  | 29820  | 61937  | 4       |
| getStakeInfo                                                             | 7222            | 10609  | 9438   | 17950  | 13      |
| onERC721Received                                                         | 957             | 957    | 957    | 957    | 23      |
| setRewardsPerUnitTime                                                    | 632             | 65412  | 92402  | 103202 | 3       |
| setTimeUnit                                                              | 742             | 65526  | 92518  | 103318 | 3       |
| stake                                                                    | 5690            | 264175 | 353540 | 355540 | 11      |
| withdraw                                                                 | 4316            | 23466  | 20810  | 49311  | 5       |

Average change:
- claimRewards: `31874 - 31866 = 8` gas saved
- getStakeInfo: `10615 - 10609 = 6` gas saved
- onERC721Received: `974 - 957 = 17` gas saved
- setRewardPerUnitTime: `65416 - 65412 = 4` gas saved
- setTimeUnit: `65530 - 65526 = 4` gas saved
- stake: `264347 - 264175 = 172` gas saved
- withdraw: `23533 - 23466 = 67` gas saved

## [G-02] Use bitmaps instead of bools when a significant amount of booleans are used

Before:
```solidity
    mapping(address => bool) public isIndexed;
```

After:
```solidity
    BitMaps.BitMap internal isIndexed;
```

Before:
| Function Name                                                            | min             | avg    | median | max    | # calls |
|--------------------------------------------------------------------------|-----------------|--------|--------|--------|---------|
| stake                                                                    | 5690            | 264347 | 353748 | 355748 | 11      |


After:
| Function Name                                                            | min             | avg    | median | max    | # calls |
|--------------------------------------------------------------------------|-----------------|--------|--------|--------|---------|
| stake                                                                    | 5690            | 234678 | 310227 | 312227 | 11      |

Average change:
- stake: `264347 - 234678 = 29_669` gas saved

This is a big saving!

## Todo

- stuff to do with lists
