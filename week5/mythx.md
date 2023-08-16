# Running MythX on the StakingV2 contracts

## Setup Process

Setting up virtual env:
```bash
# create new virtual env
python3 -m venv mythx-env
# activate the virtual evn
source mythx-env/bin/activate
# install mythx-cli
pip install mythx-cli
# when finished deactivate
deactivate
```

Running mythx-cli:
```bash
# This is to select these three contracts
mythx analyze contracts/EscrowMigrator.sol:EscrowMigrator contracts/RewardEscrowV2.sol:RewardEscrowV2 contracts/StakingRewardsV2.sol:StakingRewardsV2
```

With `.mythx.yml` file:
```yml
output: mythx.json
format: json

analyze:
    mode: deep
    create-group: true
    group-name: StakingV2
    remappings:
        - "@openzeppelin/=../node_modules/@openzeppelin"
    contracts:
        - RewardEscrowV2
        - StakingRewardsV2
        - EscrowMigrator
```

I also updated the contract imports to use exact paths instead of remappings:
```solidity
import {Ownable2StepUpgradeable} from
    "../node_modules/@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";
```
## Results

MythX found 3 low level issues in `StakingRewardsV2`:

- SWC-120
  - Low
  - Potential use of "block.number" as source of randonmness.
  - StakingRewardsV2.sol
  - L: 578 C: 67
- SWC-120
  - Low
  - Potential use of "block.number" as source of randonmness.
  - StakingRewardsV2.sol
  - L: 598 C: 67
- SWC-120
  - Low
  - Potential use of "block.number" as source of randonmness.
  - StakingRewardsV2.sol
  - L: 617 C: 54

Again, these are all false positives.
