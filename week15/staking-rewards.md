# StakingRewards Gas Optimizations

## Gas useage before changes are made


Before:
```
|  StakingRewards       ·  exit                              ·      172775  ·     243975  ·           208375  ·            2  ·       8.78  │
························|····································|··············|·············|···················|···············|··············
|  StakingRewards       ·  getReward                         ·      138477  ·     189444  ·           167652  ·            4  ·       7.06  │
························|····································|··············|·············|···················|···············|··············
|  StakingRewards       ·  notifyRewardAmount                ·       67293  ·     119112  ·           109610  ·           18  ·       4.62  │
························|····································|··············|·············|···················|···············|··············
|  StakingRewards       ·  recoverERC20                      ·           -  ·          -  ·            64686  ·            4  ·       2.72  │
························|····································|··············|·············|···················|···············|··············
|  StakingRewards       ·  setPaused                         ·       30279  ·      52404  ·            46873  ·            4  ·       1.97  │
························|····································|··············|·············|···················|···············|··············
|  StakingRewards       ·  setRewardsDistribution            ·       29005  ·      29017  ·            29013  ·            3  ·       1.22  │
························|····································|··············|·············|···················|···············|··············
|  StakingRewards       ·  setRewardsDuration                ·       32018  ·      32030  ·            32027  ·            4  ·       1.35  │
························|····································|··············|·············|···················|···············|··············
|  StakingRewards       ·  stake                             ·           -  ·          -  ·           146866  ·           12  ·       6.19  │
························|····································|··············|·············|···················|···············|··············
|  StakingRewards       ·  withdraw                          ·       99038  ·     175723  ·           137381  ·            2  ·       5.79  │
```

## [G-01] Use immutable variables

The following variables could be immutable:
```solidity
    IERC20 public rewardsToken;
    IERC20 public stakingToken;
```

This would require upgrading to solidity `^0.6.15`.

I didn't gas test this as the improvement is obvious, and it would require upgrading all the entire system to match.

## [G-02] Start storage variables as non-zero

The variables `periodFinish`, `rewardRate` and `lastUpdateTime` do not actually have to begin set as `0`. We can safely start them at `1`. This will increase the deployment cost but will save the first caller of `notifyRewardAmount` a lot of gas.

Before:
```solidity
    // gas used in first call = 109_610
    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public lastUpdateTime;
```

After:
```solidity
    // gas used in first call = 69_710
    uint256 public periodFinish = 1;
    uint256 public rewardRate = 1;
    uint256 public lastUpdateTime = 1;
```

```
Before:
|  StakingRewards       ·  notifyRewardAmount                ·       67293  ·     119112  ·           109610  ·           18  ·       4.61  │
After:
|  StakingRewards       ·  notifyRewardAmount                ·       66890  ·      87830  ·            69710  ·           18  ·       2.93  │
```

## [G-03] Cache storage variables: write and read storage variables exactly once

The `notifyRewardAmount` does not take full advantage of caching storage reads:

Before:
```solidity
    // average gas used = 109610
    function notifyRewardAmount(uint256 reward) external onlyRewardsDistribution updateReward(address(0)) {
        if (block.timestamp >= periodFinish) {
            rewardRate = reward.div(rewardsDuration);
        } else {
            uint256 remaining = periodFinish.sub(block.timestamp);
            uint256 leftover = remaining.mul(rewardRate);
            rewardRate = reward.add(leftover).div(rewardsDuration);
        }

        // Ensure the provided reward amount is not more than the balance in the contract.
        // This keeps the reward rate in the right range, preventing overflows due to
        // very high values of rewardRate in the earned and rewardsPerToken functions;
        // Reward + leftover must be less than 2^256 / 10^18 to avoid overflow.
        uint balance = rewardsToken.balanceOf(address(this));
        require(rewardRate <= balance.div(rewardsDuration), "Provided reward too high");

        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp.add(rewardsDuration);
        emit RewardAdded(reward);
    }
```

After:
```solidity
    // average gas used = 109430
    function notifyRewardAmount(uint256 reward) external onlyRewardsDistribution updateReward(address(0)) {
        uint256 _periodFinish = periodFinish;
        uint256 _rewardsDuration = rewardsDuration;
        if (block.timestamp >= _periodFinish) {
            rewardRate = reward.div(_rewardsDuration);
        } else {
            uint256 remaining = _periodFinish.sub(block.timestamp);
            uint256 leftover = remaining.mul(rewardRate);
            rewardRate = reward.add(leftover).div(_rewardsDuration);
        }


        // Ensure the provided reward amount is not more than the balance in the contract.
        // This keeps the reward rate in the right range, preventing overflows due to
        // very high values of rewardRate in the earned and rewardsPerToken functions;
        // Reward + leftover must be less than 2^256 / 10^18 to avoid overflow.
        uint balance = rewardsToken.balanceOf(address(this));
        require(rewardRate <= balance.div(_rewardsDuration), "Provided reward too high");

        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp.add(_rewardsDuration);
        emit RewardAdded(reward);
    }
```

```
Before:
|  StakingRewards       ·  notifyRewardAmount                ·       67293  ·     119112  ·           109610  ·           18  ·       4.61  │
After:
|  StakingRewards       ·  notifyRewardAmount                ·       67019  ·     118938  ·           109430  ·           18  ·       4.61  │
```
