# Week 5 - Static Analysis and Mutation Testing

## Markdown document 1.1 - Run Slither on a Codebase

- [Exercise 1.1](./slither.md)

## Markdown document 1.2 - Run MythX on a Codebase

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
