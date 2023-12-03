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

## [G-03] Pack structs

Before:
```
    struct StakingCondition {
        uint256 timeUnit;
        uint256 rewardsPerUnitTime;
        uint256 startTimestamp;
        uint256 endTimestamp;
    }
```

After:
```
    struct StakingCondition {
        uint136 rewardsPerUnitTime;
        uint40 timeUnit;
        uint40 startTimestamp;
        uint40 endTimestamp;
    }
```

Before:
| Function Name                                                            | min             | avg    | median | max    | # calls |
|--------------------------------------------------------------------------|-----------------|--------|--------|--------|---------|
| claimRewards                                                             | 5895            | 31874  | 29827  | 61949  | 4       |
| getStakeInfo                                                             | 7228            | 10615  | 9444   | 17956  | 13      |
| setRewardsPerUnitTime                                                    | 632             | 65416  | 92408  | 103208 | 3       |
| setTimeUnit                                                              | 742             | 65530  | 92524  | 103324 | 3       |
| withdraw                                                                 | 4316            | 23533  | 20940  | 49415  | 5       |

After:
| Function Name                                                            | min             | avg    | median | max    | # calls |
|--------------------------------------------------------------------------|-----------------|--------|--------|--------|---------|
| claimRewards                                                             | 5694            | 28684  | 26647  | 55748  | 4       |
| getStakeInfo                                                             | 7027            | 9438   | 9072   | 11755  | 13      |
| setRewardsPerUnitTime                                                    | 632             | 20294  | 26325  | 33925  | 3       |
| setTimeUnit                                                              | 742             | 20411  | 26446  | 34046  | 3       |
| withdraw                                                                 | 4316            | 21269  | 14739  | 44454  | 5       |

Average change:
- claimRewards: `31874 - 28684 = 3_190` gas saved
- getStakeInfo: `10615 - 9438 = 1_177` gas saved
- setRewardPerUnitTime: `65416 - 20294 = 45_122` gas saved
- setTimeUnit: `65530 - 20411 = 45_119` gas saved
- withdraw: `23533 - 21269 = 2_264` gas saved

Again very healthy savings.

## [G-04] Use storage pointers instead of memory where appropriate

There are numerous places throughout this codebase where memory is used where storage pointers could be used instead.

Before
```solidity
    ...
        StakingCondition memory condition = stakingConditions[nextConditionId - 1];
    ...
        StakingCondition memory condition = stakingConditions[nextConditionId - 1];
    ...
        uint256[] memory _indexedTokens = indexedTokens;
    ...
            address[] memory _stakersArray = stakersArray;
    ...
        Staker memory staker = stakers[_staker];
    ...
            StakingCondition memory condition = stakingConditions[i];
    ...
```

After
```solidity
    ...
        StakingCondition storage condition = stakingConditions[nextConditionId - 1];
    ...
        StakingCondition storage condition = stakingConditions[nextConditionId - 1];
    ...
        uint256[] storage _indexedTokens = indexedTokens;
    ...
            address[] storage _stakersArray = stakersArray;
    ...
        Staker storage staker = stakers[_staker];
    ...
            StakingCondition storage condition = stakingConditions[i];
    ...
```

Before:
| Deployment Cost                                                          | Deployment Size |        |        |        |         |
|--------------------------------------------------------------------------|-----------------|--------|--------|--------|---------|
| 1977635                                                                  | 10620           |        |        |        |         |
| Function Name                                                            | min             | avg    | median | max    | # calls |
| claimRewards                                                             | 5895            | 31874  | 29827  | 61949  | 4       |
| getStakeInfo                                                             | 7228            | 10615  | 9444   | 17956  | 13      |
| setRewardsPerUnitTime                                                    | 632             | 65416  | 92408  | 103208 | 3       |
| setTimeUnit                                                              | 742             | 65530  | 92524  | 103324 | 3       |
| withdraw                                                                 | 4316            | 23533  | 20940  | 49415  | 5       |

After:
| Deployment Cost                                                          | Deployment Size |        |        |        |         |
|--------------------------------------------------------------------------|-----------------|--------|--------|--------|---------|
| 1908957                                                                  | 10277           |        |        |        |         |
| Function Name                                                            | min             | avg    | median | max    | # calls |
| claimRewards                                                             | 5601            | 30595  | 28563  | 59655  | 4       |
| getStakeInfo                                                             | 7215            | 10701  | 9945   | 16405  | 13      |
| setRewardsPerUnitTime                                                    | 632             | 64628  | 92176  | 101076 | 3       |
| setTimeUnit                                                              | 742             | 64743  | 92294  | 101194 | 3       |
| withdraw                                                                 | 4316            | 22683  | 18646  | 47692  | 5       |

Average change:
- claimRewards: `31874 - 30595 = 1_279` gas saved
- getStakeInfo: `10615 - 10701 = 86` EXTRA gas used
  - So this is more expensive here on average, although it is cheaper in the max case - `17956 - 16405 = 1_551` gas saved
- setRewardPerUnitTime: `65416 - 64628 = 788` gas saved
- setTimeUnit: `65530 - 64743 = 787` gas saved
- withdraw: `23533 - 22683 = 850` gas saved
- deployment cost: `1977635 - 1908957 = 6_678` gas saved

## [G-05] Using mappings instead of arrays to avoid length checks

Before:
```solidity
    uint256[] public indexedTokens;
```

After:
```solidity
    mapping(uint256 => uint256) public indexedTokens;
```

Before:
| Deployment Cost                                                          | Deployment Size |        |        |        |         |
|--------------------------------------------------------------------------|-----------------|--------|--------|--------|---------|
| 1977635                                                                  | 10620           |        |        |        |         |
| Function Name                                                            | min             | avg    | median | max    | # calls |
| getStakeInfo                                                             | 7228            | 10615  | 9444   | 17956  | 13      |

After:
| Deployment Cost                                                          | Deployment Size |        |        |        |         |
|--------------------------------------------------------------------------|-----------------|--------|--------|--------|---------|
| 1967221                                                                  | 10568           |        |        |        |         |
| Function Name                                                            | min             | avg    | median | max    | # calls |
| getStakeInfo                                                             | 6842            | 10381  | 9304   | 17817  | 13      |

Average change:
- getStakeInfo: `10615 - 10381 = 234` gas saved

## [G-06] Calling functions via interface incurs memory expansion costs, so use assembly to re-use data already in memory

Instead of using the `IERC721` interface to call `safeTransferFrom`, use assembly to call the functions directly.

Before:
```solidity
        for (uint256 i = 0; i < len; ++i) {
            isStaking = 2;
            IERC721(_stakingToken).safeTransferFrom(_stakeMsgSender(), address(this), _tokenIds[i]);
            ...
        }
        ...
        for (uint256 i = 0; i < len; ++i) {
            require(stakerAddress[_tokenIds[i]] == _stakeMsgSender(), "Not staker");
            stakerAddress[_tokenIds[i]] = address(0);
            IERC721(_stakingToken).safeTransferFrom(address(this), _stakeMsgSender(), _tokenIds[i]);
        }
```

After:
```solidity
        for (uint256 i = 0; i < len; ++i) {
            isStaking = 2;
            uint256 tokenId = _tokenIds[i];
            assembly {
                let pointer := mload(0x40)

                mstore(0x00, hex"42842e0e")
                mstore(0x04, caller())
                mstore(0x24, address())
                mstore(0x44, tokenId)
    
                if iszero(extcodesize(_stakingToken)) {
                    revert(0x00, 0x00) // revert if address has no code deployed to it
                }
    
                // gas, address, value, argsOffset, argsSize, retOffset, retSize
                let success := call(gas(), _stakingToken, 0x00, 0x00, 0x64, 0x00, 0x80)

                
                if iszero(success) {
                    revert(0x00, 0x80)
                }

                mstore(0x40, pointer)
                mstore(0x60, 0)
            }
            ...
        }
        ...
        for (uint256 i = 0; i < len; ++i) {
            require(stakerAddress[_tokenIds[i]] == _stakeMsgSender(), "Not staker");
            stakerAddress[_tokenIds[i]] = address(0);
            uint256 tokenId = _tokenIds[i];
            assembly {
                let pointer := mload(0x40)

                mstore(0x00, hex"42842e0e")
                mstore(0x04, address())
                mstore(0x24, caller())
                mstore(0x44, tokenId)
    
                if iszero(extcodesize(_stakingToken)) {
                    revert(0x00, 0x00) // revert if address has no code deployed to it
                }
    
                // gas, address, value, argsOffset, argsSize, retOffset, retSize
                let success := call(gas(), _stakingToken, 0x00, 0x00, 0x64, 0x00, 0x80)

                
                if iszero(success) {
                    revert(0x00, 0x80)
                }

                mstore(0x40, pointer)
                mstore(0x60, 0)
            }
        }
```

Before:
| Deployment Cost                                                          | Deployment Size |        |        |        |         |
|--------------------------------------------------------------------------|-----------------|--------|--------|--------|---------|
| 1977635                                                                  | 10620           |        |        |        |         |
| Function Name                                                            | min             | avg    | median | max    | # calls |
| stake                                                                    | 5690            | 264347 | 353748 | 355748 | 11      |
| withdraw                                                                 | 4316            | 23533  | 20940  | 49415  | 5       |

After;
| Deployment Cost                                                          | Deployment Size |        |        |        |         |
|--------------------------------------------------------------------------|-----------------|--------|--------|--------|---------|
| 1963213                                                                  | 10548           |        |        |        |         |
| Function Name                                                            | min             | avg    | median | max    | # calls |
| stake                                                                    | 5690            | 264023 | 353310 | 355310 | 11      |
| withdraw                                                                 | 4316            | 23437  | 20940  | 49127  | 5       |

Average change:
- stake: `264347 - 264023 = 324` gas saved
- withdraw: `23533 - 23437 = 96` gas saved
- deployment cost: `1977635 - 1963213 = 14_422` gas saved

## [G-07] Remove SafeMath - it is not needed in solidity version 0.8.0 and above

Before:
```solidity
            (bool noOverflowProduct, uint256 rewardsProduct) = SafeMath.tryMul(
                (endTime - startTime) * staker.amountStaked,
                condition.rewardsPerUnitTime
            );
            (bool noOverflowSum, uint256 rewardsSum) = SafeMath.tryAdd(_rewards, rewardsProduct / condition.timeUnit);
```

After:
```solidity
            uint256 rewardsProduct = ((endTime - startTime) * staker.amountStaked) * condition.rewardsPerUnitTime;
            uint256 rewardsSum = _rewards + (rewardsProduct / condition.timeUnit);
```

Before:
| Deployment Cost                                                          | Deployment Size |        |        |        |         |
|--------------------------------------------------------------------------|-----------------|--------|--------|--------|---------|
| 1977635                                                                  | 10620           |        |        |        |         |
| Function Name                                                            | min             | avg    | median | max    | # calls |
| claimRewards                                                             | 5895            | 31874  | 29827  | 61949  | 4       |
| getStakeInfo                                                             | 7228            | 10615  | 9444   | 17956  | 13      |
| withdraw                                                                 | 4316            | 23533  | 20940  | 49415  | 5       |

After:
| Deployment Cost                                                          | Deployment Size |        |        |        |         |
|--------------------------------------------------------------------------|-----------------|--------|--------|--------|---------|
| 1946399                                                                  | 10464           |        |        |        |         |
| Function Name                                                            | min             | avg    | median | max    | # calls |
| claimRewards                                                             | 5802            | 31774  | 29744  | 61807  | 4       |
| getStakeInfo                                                             | 7135            | 10455  | 9160   | 17863  | 13      |
| withdraw                                                                 | 4316            | 23469  | 20847  | 49301  | 5       |

Average change:
- claimRewards: `31874 - 31774 = 100` gas saved
- getStakeInfo: `10615 - 10455 = 160` gas saved
- withdraw: `23533 - 23469 = 64` gas saved
- deployment cost: `1977635 - 1946399 = 31_236` gas saved

## Todo

- stuff to do with lists
- memory stuff
- getStakeInfo indexedTokens loop cache storage reads
