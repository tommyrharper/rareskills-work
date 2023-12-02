# Trader Joe TokenVesting

## Gas usage without optimizations

```
·------------------------------------|---------------------------|-------------|-----------------------------·
|        Solc version: 0.6.12        ·  Optimizer enabled: true  ·  Runs: 200  ·  Block limit: 30000000 gas  │
·····································|···························|·············|······························
|  Methods                           ·               5 gwei/gas                ·       2139.75 usd/eth       │
·················|···················|·············|·············|·············|···············|··············
|  Contract      ·  Method           ·  Min        ·  Max        ·  Avg        ·  # calls      ·  usd (avg)  │
·················|···················|·············|·············|·············|···············|··············
|  TokenVesting  ·  emergencyRevoke  ·          -  ·          -  ·      79522  ·            1  ·       0.85  │
·················|···················|·············|·············|·············|···············|··············
|  TokenVesting  ·  release          ·      69505  ·      91919  ·      81944  ·            3  ·       0.88  │
·················|···················|·············|·············|·············|···············|··············
|  TokenVesting  ·  revoke           ·      85286  ·      95116  ·      90201  ·            2  ·       0.97  │
·················|···················|·············|·············|·············|···············|··············
|  Deployments                       ·                                         ·  % of limit   ·             │
·····································|·············|·············|·············|···············|··············
|  TokenVesting                      ·          -  ·          -  ·     995026  ·        3.3 %  ·      10.65  │
·------------------------------------|-------------|-------------|-------------|---------------|-------------·
```

## [G-01] Variables that are never updated should be immutable or constant

The following variables can be updated to immutable (this requires upgrading from solidity `v0.6.0` to `v0.6.5`):
```solidity
    // beneficiary of tokens after they are released
    address private _beneficiary;

    // Durations and timestamps are expressed in UNIX time, the same units as block.timestamp.
    uint256 private _cliff;
    uint256 private _start;
    uint256 private _duration;

    bool private _revocable;
```

After:
```solidity
    // beneficiary of tokens after they are released
    address private immutable _beneficiary;

    // Durations and timestamps are expressed in UNIX time, the same units as block.timestamp.
    uint256 private immutable _cliff;
    uint256 private immutable _start;
    uint256 private immutable _duration;

    bool private immutable _revocable;
```

Gas usage after:
```
·------------------------------------|---------------------------|-------------|-----------------------------·
|        Solc version: 0.6.12        ·  Optimizer enabled: true  ·  Runs: 200  ·  Block limit: 30000000 gas  │
·····································|···························|·············|······························
|  Methods                           ·               5 gwei/gas                ·       2142.05 usd/eth       │
·················|···················|·············|·············|·············|···············|··············
|  Contract      ·  Method           ·  Min        ·  Max        ·  Avg        ·  # calls      ·  usd (avg)  │
·················|···················|·············|·············|·············|···············|··············
|  TokenVesting  ·  emergencyRevoke  ·          -  ·          -  ·      77416  ·            1  ·       0.83  │
·················|···················|·············|·············|·············|···············|··············
|  TokenVesting  ·  release          ·      61093  ·      83292  ·      73460  ·            3  ·       0.79  │
·················|···················|·············|·············|·············|···············|··············
|  TokenVesting  ·  revoke           ·      81080  ·      86492  ·      83786  ·            2  ·       0.90  │
·················|···················|·············|·············|·············|···············|··············
|  Deployments                       ·                                         ·  % of limit   ·             │
·····································|·············|·············|·············|···············|··············
|  TokenVesting                      ·          -  ·          -  ·     958586  ·        3.2 %  ·      10.27  │
·------------------------------------|-------------|-------------|-------------|---------------|-------------·
```

We can see the following improvements:
- emergencyRevoke: 79522 - 77416 = 2_106 gas saved on average
- release: 81944 - 73460 = 8_484 gas saved on average
- revoke: 90201 - 83786 = 6_415 gas saved on average

## [G-02] Pack related variables

Instead of having the following two mappings:
```solidity
    mapping(address => uint256) private _released;
    mapping(address => bool) private _revoked;
```

It is possible to pack `_released` and `_revoked` into a struct for gas savings:

```solidity
    struct TokenData {
        uint248 released;
        bool revoked;
    }

    mapping(address => TokenData) private _tokenData;
```

This leads to the following gas savings:
```
Before:
·················|···················|·············|·············|·············|···············|··············
|  TokenVesting  ·  release          ·      69505  ·      91919  ·      81944  ·            3  ·       0.88  │
·················|···················|·············|·············|·············|···············|··············
|  TokenVesting  ·  revoke           ·      85286  ·      95116  ·      90201  ·            2  ·       0.97  │
·················|···················|·············|·············|·············|···············|··············
After:
·················|···················|·············|·············|·············|···············|··············
|  TokenVesting  ·  release          ·      50636  ·      90150  ·      75136  ·            3  ·       0.81  │
·················|···················|·············|·············|·············|···············|··············
|  TokenVesting  ·  revoke           ·      83354  ·      93201  ·      88278  ·            2  ·       0.95  │
·················|···················|·············|·············|·············|···············|··············
```

As we can see:
- release: 81944 - 75136 = 6_808 gas saved on average
- revoke: 90201 - 88278 = 1_923 gas saved on average


## [G-03] Cache storage variables: write and read storage variables exactly once

When we call `revoke` it reads `_revoked[address(token)]` from storage up to two times, and `_released[address(token)]` two times.

This can be reduced to just one read of each.

Before:
```solidity
    function revoke(IERC20 token) public onlyOwner {
        require(_revocable, "TokenVesting: cannot revoke");
        require(!_revoked[address(token)], "TokenVesting: token already revoked");

        uint256 balance = token.balanceOf(address(this));

        uint256 unreleased = _releasableAmount(token);
        uint256 refund = balance.sub(unreleased);

        _revoked[address(token)] = true;

        token.safeTransfer(owner(), refund);

        emit TokenVestingRevoked(address(token));
    }

    function _releasableAmount(IERC20 token) private view returns (uint256) {
        return _vestedAmount(token).sub(_released[address(token)]);
    }

    function _vestedAmount(IERC20 token) private view returns (uint256) {
        uint256 currentBalance = token.balanceOf(address(this));
        uint256 totalBalance = currentBalance.add(_released[address(token)]);

        if (block.timestamp < _cliff) {
            return 0;
        } else if (block.timestamp >= _start.add(_duration) || _revoked[address(token)]) {
            return totalBalance;
        } else {
            return totalBalance.mul(block.timestamp.sub(_start)).div(_duration);
        }
    }
```

After:
```solidity
    function revoke(IERC20 token) public onlyOwner {
        require(_revocable, "TokenVesting: cannot revoke");
        bool revoked = _revoked[address(token)];
        require(!revoked, "TokenVesting: token already revoked");

        uint256 balance = token.balanceOf(address(this));

        uint256 released = _released[address(token)];
        uint256 unreleased = _releasableAmount(token, released, revoked);
        uint256 refund = balance.sub(unreleased);

        _revoked[address(token)] = true;

        token.safeTransfer(owner(), refund);

        emit TokenVestingRevoked(address(token));
    }

    function _releasableAmount(IERC20 token, uint256 released, bool revoked) private view returns (uint256) {
        return _vestedAmount(token, released, revoked).sub(released);
    }

    function _vestedAmount(IERC20 token, uint256 released, bool revoked) private view returns (uint256) {
        uint256 currentBalance = token.balanceOf(address(this));
        uint256 totalBalance = currentBalance.add(released);

        if (block.timestamp < _cliff) {
            return 0;
        } else if (block.timestamp >= _start.add(_duration) || revoked) {
            return totalBalance;
        } else {
            return totalBalance.mul(block.timestamp.sub(_start)).div(_duration);
        }
    }
```

This saves on average `90201 - 89943 = 258` gas:
```
Before:
|  TokenVesting  ·  revoke           ·      85286  ·      95116  ·      90201  ·            2  ·       0.97  │
After:
|  TokenVesting  ·  revoke           ·      85124  ·      94761  ·      89943  ·            2  ·       0.97  │
```

## [G-04] Cache calls to external contracts where it makes sense (like caching return data from chainlink oracle)

There are unnecessary duplicate `token.balanceOf` calls.

Before:
```solidity
    function revoke(IERC20 token) public onlyOwner {
        require(_revocable, "TokenVesting: cannot revoke");
        require(!_revoked[address(token)], "TokenVesting: token already revoked");

        uint256 balance = token.balanceOf(address(this));

        uint256 unreleased = _releasableAmount(token);
        uint256 refund = balance.sub(unreleased);

        _revoked[address(token)] = true;

        token.safeTransfer(owner(), refund);

        emit TokenVestingRevoked(address(token));
    }

    function _releasableAmount(IERC20 token) private view returns (uint256) {
        return _vestedAmount(token).sub(_released[address(token)]);
    }

    function _vestedAmount(IERC20 token) private view returns (uint256) {
        uint256 currentBalance = token.balanceOf(address(this));
        uint256 totalBalance = currentBalance.add(_released[address(token)]);

        if (block.timestamp < _cliff) {
            return 0;
        } else if (block.timestamp >= _start.add(_duration) || _revoked[address(token)]) {
            return totalBalance;
        } else {
            return totalBalance.mul(block.timestamp.sub(_start)).div(_duration);
        }
    }
```

After:
```solidity
    function revoke(IERC20 token) public onlyOwner {
        require(_revocable, "TokenVesting: cannot revoke");
        require(!_revoked[address(token)], "TokenVesting: token already revoked");

        uint256 balance = token.balanceOf(address(this));

        uint256 unreleased = _releasableAmount(token, balance);
        uint256 refund = balance.sub(unreleased);

        _revoked[address(token)] = true;

        token.safeTransfer(owner(), refund);

        emit TokenVestingRevoked(address(token));
    }

    function _releasableAmount(IERC20 token, uint256 balance) private view returns (uint256) {
        return _vestedAmount(token, balance).sub(_released[address(token)]);
    }

    function _vestedAmount(IERC20 token, uint256 balance) private view returns (uint256) {
        uint256 totalBalance = balance.add(_released[address(token)]);

        if (block.timestamp < _cliff) {
            return 0;
        } else if (block.timestamp >= _start.add(_duration) || _revoked[address(token)]) {
            return totalBalance;
        } else {
            return totalBalance.mul(block.timestamp.sub(_start)).div(_duration);
        }
    }
```

```
Before:
|  TokenVesting  ·  revoke           ·      85286  ·      95116  ·      90201  ·            2  ·       0.97  │
After:
|  TokenVesting  ·  revoke           ·      84323  ·      94153  ·      89238  ·            2  ·       0.96  │
```

As we can see, on average for `revoke`, `90201 - 89238 = 963` gas saved.

## [G-05] Use internal functions to reduce deployed bytecode size

There is a bunch of code that repeats itself in the contract that can be extracted into `internal` helper function to save deployed bytecode cost. Of course this comes at some extra expense in terms of `JUMP` opcodes at runtime, however, as we will see with further analysis, in this instance the tradeoff is likely worth it.

Before:
```solidity
    function release(IERC20 token) public {
        uint256 unreleased = _releasableAmount(token);

        require(unreleased > 0, "TokenVesting: no tokens are due");

        _released[address(token)] = _released[address(token)].add(unreleased);

        token.safeTransfer(_beneficiary, unreleased);

        emit TokensReleased(address(token), unreleased);
    }

    function revoke(IERC20 token) public onlyOwner {
        require(_revocable, "TokenVesting: cannot revoke");
        require(!_revoked[address(token)], "TokenVesting: token already revoked");

        uint256 balance = token.balanceOf(address(this));

        uint256 unreleased = _releasableAmount(token);
        uint256 refund = balance.sub(unreleased);

        _revoked[address(token)] = true;

        token.safeTransfer(owner(), refund);

        emit TokenVestingRevoked(address(token));
    }
```

After:
```solidity
    function canRevoke(IERC20 token) internal {
        require(_revocable, "TokenVesting: cannot revoke");
        require(!_revoked[address(token)], "TokenVesting: token already revoked");
    }

    function applyRevoke(IERC20 token, uint256 refund) internal {
        _revoked[address(token)] = true;

        token.safeTransfer(owner(), refund);

        emit TokenVestingRevoked(address(token));
    }

    function revoke(IERC20 token) public onlyOwner {
        canRevoke(token);

        uint256 balance = token.balanceOf(address(this));

        uint256 unreleased = _releasableAmount(token);
        uint256 refund = balance.sub(unreleased);

        applyRevoke(token, refund);
    }

    function emergencyRevoke(IERC20 token) public onlyOwner {
        canRevoke(token);

        uint256 balance = token.balanceOf(address(this));

        applyRevoke(token, balance);
    }
```

```
Before:
·------------------------------------|---------------------------|-------------|-----------------------------·
|        Solc version: 0.6.12        ·  Optimizer enabled: true  ·  Runs: 200  ·  Block limit: 30000000 gas  │
·····································|···························|·············|······························
|  Methods                           ·               5 gwei/gas                ·       2139.75 usd/eth       │
·················|···················|·············|·············|·············|···············|··············
|  Contract      ·  Method           ·  Min        ·  Max        ·  Avg        ·  # calls      ·  usd (avg)  │
·················|···················|·············|·············|·············|···············|··············
|  TokenVesting  ·  emergencyRevoke  ·          -  ·          -  ·      79522  ·            1  ·       0.85  │
·················|···················|·············|·············|·············|···············|··············
|  TokenVesting  ·  revoke           ·      85286  ·      95116  ·      90201  ·            2  ·       0.97  │
·················|···················|·············|·············|·············|···············|··············
|  Deployments                       ·                                         ·  % of limit   ·             │
·····································|·············|·············|·············|···············|··············
|  TokenVesting                      ·          -  ·          -  ·     995026  ·        3.3 %  ·      10.65  │
·------------------------------------|-------------|-------------|-------------|---------------|-------------·
After:
·------------------------------------|---------------------------|-------------|-----------------------------·
|        Solc version: 0.6.12        ·  Optimizer enabled: true  ·  Runs: 200  ·  Block limit: 30000000 gas  │
·····································|···························|·············|······························
|  Methods                           ·               5 gwei/gas                ·       2158.40 usd/eth       │
·················|···················|·············|·············|·············|···············|··············
|  Contract      ·  Method           ·  Min        ·  Max        ·  Avg        ·  # calls      ·  usd (avg)  │
·················|···················|·············|·············|·············|···············|··············
|  TokenVesting  ·  emergencyRevoke  ·          -  ·          -  ·      79585  ·            1  ·       0.86  │
·················|···················|·············|·············|·············|···············|··············
|  TokenVesting  ·  revoke           ·      85349  ·      95179  ·      90264  ·            2  ·       0.97  │
·················|···················|·············|·············|·············|···············|··············
|  Deployments                       ·                                         ·  % of limit   ·             │
·····································|·············|·············|·············|···············|··············
|  TokenVesting                      ·          -  ·          -  ·     940411  ·        3.1 %  ·      10.15  │
·------------------------------------|-------------|-------------|-------------|---------------|-------------·
```

As we can see, on deployment we save `995026 - 940411 = 54_615` gas.

Then at runtime, we pay an extra:
- `79585 - 79522 = 63` gas per `emergencyRevoke` call.
- `90264 - 90201 = 63` gas per `revoke` call.

Now to judge this tradeoff, we have to consider, that the `owner` of the contract is also set as the deployer, and only the `owner` can call these admin functions `emergencyRevoke`, `revoke`. So it is not a question of user vs deployer cost, the same entity is doing both.

So we can do some simple math to see if this is worth it - `54_615 / 63 = ~867`. Therefore, if the deployer of the contract, expects to revoke packages less than `867` times, this optimization is worth.

For most use cases of this kind of contract, it seems unlikely the admin will revoke packages `867` times, so in normal usage this optimization can be safely recommended.




