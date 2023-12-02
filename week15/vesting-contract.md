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

