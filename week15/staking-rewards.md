# Synthetix StakingRewards Gas Optimizations

Note - I didn't write my own tests for this, I just reused the ones in the `synthetix` repo, and turned the `gas-reporter` on.

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

## [G-01] Variables that are never updated should be immutable or constant

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

## [G-04] Pack related variables

The variables `periodFinish` and `lastUpdateTime` are almost always used together all across the codebase. As they are time lengths they can safely fit in a `uint128` rather than a `uint256`. Hence the following change works:


Before:
```solidity
    uint256 public periodFinish = 0;
    uint256 public lastUpdateTime;
```

After:
```solidity
    uint128 public periodFinish = 0;
    uint128 public lastUpdateTime;
```

This leads to the following average gas savings:
- exit: 208375 - 207133 = 1_242 gas
- getRewards: 167652 - 166197 = 1_455 gas
- notifyRewardAmount: 109610 - 92264 = 17_346 gas
- stake: 146866 - 145053 = 1_813 gas
- withdraw: 137381 - 135957 = 1_424 gas


## [G-05] Avoid having ERC20 token balances go to zero, always keep a small amount

If you force the `withdraw` function to always allow users to leave at least 1 wei in the contract, then you can save gas in many cases.

Before:
```solidity
    // average gas used = 137381
    function withdraw(uint256 amount) public nonReentrant updateReward(msg.sender) {
        require(amount > 0, "Cannot withdraw 0");
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        stakingToken.safeTransfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount);
    }
```

After:
```solidity
    // average gas used = 134354
    function withdraw(uint256 amount) public nonReentrant updateReward(msg.sender) {
        require(amount > 0, "Cannot withdraw 0");
        uint256 __totalSupply = _totalSupply;
        if (__totalSupply - amount == 0) {
            amount -= 1;
        }
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        stakingToken.safeTransfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount);
    }
```

You can see this on average saves `137381 - 134354 = 3_027` gas. However the minimum gas used has increased, and the maximum gas used. This is due to the extra logic required to support this. However on average it is saving gas.

```
Before:
|  StakingRewards       ·  withdraw                          ·       99038  ·     175723  ·           137381  ·            2  ·       5.79  │
After:
|  StakingRewards       ·  withdraw                          ·      113597  ·     175868  ·           134354  ·            3  ·       5.65  │
```

## [G-06] Custom errors are (usually) smaller than require statements

Require statements could be updated with custom errors (though this would also require increasing the compiler version to `0.8.4` or higher):

Befoer:
```solidity
require(amount > 0, "Cannot stake 0");
require(amount > 0, "Cannot withdraw 0");
require(rewardRate <= balance.div(rewardsDuration), "Provided reward too high");
require(tokenAddress != address(stakingToken), "Cannot withdraw the staking token");
require(
    block.timestamp > periodFinish,
    "Previous rewards period must be complete before changing the duration for the new period"
);
```

After:
```solidity
if (amount == 0) revert CannotStakeZero();
if (amount == 0) revert CannotWithdrawZero();
if (rewardRate > balance.div(rewardsDuration)) revert RewardTooHigh();
if (tokenAddress != address(stakingToken)) revert CannotWithdrawStakingToken();
if (block.timestamp <= periodFinish) revert RewardPeriodNotComplete(); 
```

## [G-07] Use inline assembly to check for address(0)

We can use this trick to save some gas in the `updateReward` modifier, which is used mostly everywhere:

Before:
```solidity
    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }
```

After:
```solidity
    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        bool _isZero;
        assembly {
            _isZero := iszero(account)
        }
        if (!_isZero) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }
```

Using this approach we save a small amount of gas (single digits) in the following functions:
- `exit`
- `getReward`
- `notifyRewardAmount`
- `stake`
- `withdraw`

```
Before:
|  StakingRewards       ·  exit                              ·      172775  ·     243975  ·           208375  ·            2  ·       8.78  │
························|····································|··············|·············|···················|···············|··············
|  StakingRewards       ·  getReward                         ·      138477  ·     189444  ·           167652  ·            4  ·       7.06  │
························|····································|··············|·············|···················|···············|··············
|  StakingRewards       ·  notifyRewardAmount                ·       67293  ·     119112  ·           109610  ·           18  ·       4.62  │
························|····································|··············|·············|···················|···············|··············
|  StakingRewards       ·  stake                             ·           -  ·          -  ·           146866  ·           12  ·       6.19  │
························|····································|··············|·············|···················|···············|··············
|  StakingRewards       ·  withdraw                          ·       99038  ·     175723  ·           137381  ·            2  ·       5.79  │
After:
|  StakingRewards       ·  exit                              ·      172771  ·     243971  ·           208371  ·            2  ·       8.78  │
························|····································|··············|·············|···················|···············|··············
|  StakingRewards       ·  getReward                         ·      138475  ·     189442  ·           167650  ·            4  ·       7.06  │
························|····································|··············|·············|···················|···············|··············
|  StakingRewards       ·  notifyRewardAmount                ·       67291  ·     119110  ·           109608  ·           18  ·       4.62  │
························|····································|··············|·············|···················|···············|··············
|  StakingRewards       ·  stake                             ·           -  ·          -  ·           146864  ·           12  ·       6.19  │
························|····································|··············|·············|···················|···············|··············
|  StakingRewards       ·  withdraw                          ·       99036  ·     175721  ·           137379  ·            2  ·       5.79  │
```

## [G-08] Use unchecked math where appropriate

In `notifyRewardAmount` we do not need to use checked math to calculate `remaining`:
```solidity
    function notifyRewardAmount(uint256 reward) external onlyRewardsDistribution updateReward(address(0)) {
        if (block.timestamp >= periodFinish) {
            rewardRate = reward.div(rewardsDuration);
        } else {
            uint256 remaining = periodFinish.sub(block.timestamp);
            uint256 leftover = remaining.mul(rewardRate);
            rewardRate = reward.add(leftover).div(rewardsDuration);
        }
        ...
    }
```

Because we check `if (block.timestamp >= periodFinish)`, we know that in the `else` block, `periodFinish > block.timestamp`.

Hence we can safely do the following:
```solidity
uint256 remaining = periodFinish - block.timestamp;
```

As this is solidity version `^0.5.16;`, we don't need to add an `unchecked` block, there is no default underflow checking. Instead we just stop using the `SafeMath` library.

You can see the minimum gas usage for `notifyRewardAmount` dropped by `67293 - 67191 = 102 gas`, and the average gas usage by `6` gas.

```
Before:
|  StakingRewards       ·  notifyRewardAmount                ·       67293  ·     119112  ·           109610  ·           18  ·       4.62  │
After:
|  StakingRewards       ·  notifyRewardAmount                ·       67191  ·     119112  ·           109604  ·           18  ·       4.62  │
```
