## Running Slither on the EscrowMigrator contract

All of these are false positives.

```
INFO:Detectors:
ERC1967UpgradeUpgradeable._functionDelegateCall(address,bytes) (node_modules/@openzeppelin/contracts-upgradeable/proxy/ERC1967/ERC1967UpgradeUpgradeable.sol#186-197) uses delegatecall to a input-controlled function id
	- (success,returndata) = target.delegatecall(data) (node_modules/@openzeppelin/contracts-upgradeable/proxy/ERC1967/ERC1967UpgradeUpgradeable.sol#193)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#controlled-delegatecall
INFO:Detectors:
EscrowMigrator._migrateEntries(address,address,uint256[]) (contracts/EscrowMigrator.sol#252-311) ignores return value by kwenta.transfer(address(rewardEscrowV2),originalEscrowAmount) (contracts/EscrowMigrator.sol#299)
EscrowMigrator._payForMigration(address) (contracts/EscrowMigrator.sol#313-319) ignores return value by kwenta.transferFrom(msg.sender,address(this),toPayNow) (contracts/EscrowMigrator.sol#316)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#unchecked-transfer
INFO:Detectors:
EscrowMigrator._registerEntries(address,uint256[]) (contracts/EscrowMigrator.sol#190-233) uses a dangerous strict equality:
	- rewardEscrowV1.balanceOf(account) == 0 (contracts/EscrowMigrator.sol#196)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#dangerous-strict-equalities
INFO:Detectors:
Reentrancy in EscrowMigrator._migrateEntries(address,address,uint256[]) (contracts/EscrowMigrator.sol#252-311):
	External calls:
	- _payForMigration(account) (contracts/EscrowMigrator.sol#257)
		- kwenta.transferFrom(msg.sender,address(this),toPayNow) (contracts/EscrowMigrator.sol#316)
	- kwenta.transfer(address(rewardEscrowV2),originalEscrowAmount) (contracts/EscrowMigrator.sol#299)
	- rewardEscrowV2.importEscrowEntry(to,entry) (contracts/EscrowMigrator.sol#300)
	State variables written after the call(s):
	- registeredEntry.migrated = true (contracts/EscrowMigrator.sol#304)
	EscrowMigrator.registeredVestingSchedules (contracts/EscrowMigrator.sol#73) can be used in cross function reentrancies:
	- EscrowMigrator._migrateEntries(address,address,uint256[]) (contracts/EscrowMigrator.sol#252-311)
	- EscrowMigrator._registerEntries(address,uint256[]) (contracts/EscrowMigrator.sol#190-233)
	- EscrowMigrator.numberOfMigratedEntries(address) (contracts/EscrowMigrator.sol#135-143)
	- EscrowMigrator.registeredVestingSchedules (contracts/EscrowMigrator.sol#73)
	- EscrowMigrator.totalEscrowMigrated(address) (contracts/EscrowMigrator.sol#156-165)
	- EscrowMigrator.totalEscrowRegistered(address) (contracts/EscrowMigrator.sol#146-153)
Reentrancy in EscrowMigrator._payForMigration(address) (contracts/EscrowMigrator.sol#313-319):
	External calls:
	- kwenta.transferFrom(msg.sender,address(this),toPayNow) (contracts/EscrowMigrator.sol#316)
	State variables written after the call(s):
	- paidSoFar[account] += toPayNow (contracts/EscrowMigrator.sol#317)
	EscrowMigrator.paidSoFar (contracts/EscrowMigrator.sol#79) can be used in cross function reentrancies:
	- EscrowMigrator._payForMigration(address) (contracts/EscrowMigrator.sol#313-319)
	- EscrowMigrator.paidSoFar (contracts/EscrowMigrator.sol#79)
	- EscrowMigrator.toPay(address) (contracts/EscrowMigrator.sol#168-172)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#reentrancy-vulnerabilities-1
INFO:Detectors:
ERC1967UpgradeUpgradeable._upgradeToAndCallUUPS(address,bytes,bool).slot (node_modules/@openzeppelin/contracts-upgradeable/proxy/ERC1967/ERC1967UpgradeUpgradeable.sol#95) is a local variable never initialized
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#uninitialized-local-variables
INFO:Detectors:
ERC1967UpgradeUpgradeable._upgradeToAndCallUUPS(address,bytes,bool) (node_modules/@openzeppelin/contracts-upgradeable/proxy/ERC1967/ERC1967UpgradeUpgradeable.sol#85-103) ignores return value by IERC1822ProxiableUpgradeable(newImplementation).proxiableUUID() (node_modules/@openzeppelin/contracts-upgradeable/proxy/ERC1967/ERC1967UpgradeUpgradeable.sol#94-100)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#unused-return
INFO:Detectors:
Ownable2StepUpgradeable.transferOwnership(address).newOwner (node_modules/@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol#42) lacks a zero-check on :
		- _pendingOwner = newOwner (node_modules/@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol#43)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#missing-zero-address-validation
INFO:Detectors:
Reentrancy in EscrowMigrator._migrateEntries(address,address,uint256[]) (contracts/EscrowMigrator.sol#252-311):
	External calls:
	- _payForMigration(account) (contracts/EscrowMigrator.sol#257)
		- kwenta.transferFrom(msg.sender,address(this),toPayNow) (contracts/EscrowMigrator.sol#316)
	- kwenta.transfer(address(rewardEscrowV2),originalEscrowAmount) (contracts/EscrowMigrator.sol#299)
	- rewardEscrowV2.importEscrowEntry(to,entry) (contracts/EscrowMigrator.sol#300)
	State variables written after the call(s):
	- totalMigrated += migratedEscrow (contracts/EscrowMigrator.sol#310)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#reentrancy-vulnerabilities-2
INFO:Detectors:
EscrowMigrator._registerEntries(address,uint256[]) (contracts/EscrowMigrator.sol#190-233) uses timestamp for comparisons
	Dangerous comparisons:
	- endTime <= block.timestamp (contracts/EscrowMigrator.sol#217)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#block-timestamp
INFO:Detectors:
AddressUpgradeable._revert(bytes,string) (node_modules/@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol#209-221) uses assembly
	- INLINE ASM (node_modules/@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol#214-217)
StorageSlotUpgradeable.getAddressSlot(bytes32) (node_modules/@openzeppelin/contracts-upgradeable/utils/StorageSlotUpgradeable.sol#52-57) uses assembly
	- INLINE ASM (node_modules/@openzeppelin/contracts-upgradeable/utils/StorageSlotUpgradeable.sol#54-56)
StorageSlotUpgradeable.getBooleanSlot(bytes32) (node_modules/@openzeppelin/contracts-upgradeable/utils/StorageSlotUpgradeable.sol#62-67) uses assembly
	- INLINE ASM (node_modules/@openzeppelin/contracts-upgradeable/utils/StorageSlotUpgradeable.sol#64-66)
StorageSlotUpgradeable.getBytes32Slot(bytes32) (node_modules/@openzeppelin/contracts-upgradeable/utils/StorageSlotUpgradeable.sol#72-77) uses assembly
	- INLINE ASM (node_modules/@openzeppelin/contracts-upgradeable/utils/StorageSlotUpgradeable.sol#74-76)
StorageSlotUpgradeable.getUint256Slot(bytes32) (node_modules/@openzeppelin/contracts-upgradeable/utils/StorageSlotUpgradeable.sol#82-87) uses assembly
	- INLINE ASM (node_modules/@openzeppelin/contracts-upgradeable/utils/StorageSlotUpgradeable.sol#84-86)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#assembly-usage
INFO:Detectors:
Different versions of Solidity are used:
	- Version used: ['0.8.19', '>=0.5.0<0.9.0', '^0.8.0', '^0.8.1', '^0.8.2']
	- 0.8.19 (contracts/EscrowMigrator.sol#2)
	- 0.8.19 (contracts/interfaces/IEscrowMigrator.sol#2)
	- 0.8.19 (contracts/interfaces/IRewardEscrowV2.sol#2)
	- 0.8.19 (contracts/interfaces/IStakingRewardsIntegrator.sol#2)
	- 0.8.19 (contracts/interfaces/IStakingRewardsV2.sol#2)
	- >=0.5.0<0.9.0 (contracts/interfaces/IERC20.sol#2)
	- ^0.8.0 (node_modules/@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol#4)
	- ^0.8.0 (node_modules/@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol#4)
	- ^0.8.0 (node_modules/@openzeppelin/contracts-upgradeable/interfaces/IERC1967Upgradeable.sol#4)
	- ^0.8.0 (node_modules/@openzeppelin/contracts-upgradeable/interfaces/draft-IERC1822Upgradeable.sol#4)
	- ^0.8.0 (node_modules/@openzeppelin/contracts-upgradeable/proxy/beacon/IBeaconUpgradeable.sol#4)
	- ^0.8.0 (node_modules/@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol#4)
	- ^0.8.0 (node_modules/@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol#4)
	- ^0.8.0 (node_modules/@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol#4)
	- ^0.8.0 (node_modules/@openzeppelin/contracts-upgradeable/utils/StorageSlotUpgradeable.sol#4)
	- ^0.8.0 (contracts/interfaces/IKwenta.sol#3)
	- ^0.8.0 (contracts/interfaces/IRewardEscrow.sol#2)
	- ^0.8.0 (contracts/interfaces/IStakingRewards.sol#2)
	- ^0.8.1 (node_modules/@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol#4)
	- ^0.8.2 (node_modules/@openzeppelin/contracts-upgradeable/proxy/ERC1967/ERC1967UpgradeUpgradeable.sol#4)
	- ^0.8.2 (node_modules/@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol#4)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#different-pragma-directives-are-used
INFO:Detectors:
AddressUpgradeable.functionCall(address,bytes) (node_modules/@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol#85-87) is never used and should be removed
AddressUpgradeable.functionCall(address,bytes,string) (node_modules/@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol#95-100) is never used and should be removed
AddressUpgradeable.functionCallWithValue(address,bytes,uint256) (node_modules/@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol#113-119) is never used and should be removed
AddressUpgradeable.functionCallWithValue(address,bytes,uint256,string) (node_modules/@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol#127-136) is never used and should be removed
AddressUpgradeable.functionStaticCall(address,bytes) (node_modules/@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol#144-150) is never used and should be removed
AddressUpgradeable.functionStaticCall(address,bytes,string) (node_modules/@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol#158-165) is never used and should be removed
AddressUpgradeable.sendValue(address,uint256) (node_modules/@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol#60-65) is never used and should be removed
AddressUpgradeable.verifyCallResultFromTarget(address,bool,bytes,string) (node_modules/@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol#173-189) is never used and should be removed
ContextUpgradeable.__Context_init() (node_modules/@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol#19) is never used and should be removed
ContextUpgradeable.__Context_init_unchained() (node_modules/@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol#21) is never used and should be removed
ContextUpgradeable._msgData() (node_modules/@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol#27-29) is never used and should be removed
ERC1967UpgradeUpgradeable.__ERC1967Upgrade_init() (node_modules/@openzeppelin/contracts-upgradeable/proxy/ERC1967/ERC1967UpgradeUpgradeable.sol#22) is never used and should be removed
ERC1967UpgradeUpgradeable.__ERC1967Upgrade_init_unchained() (node_modules/@openzeppelin/contracts-upgradeable/proxy/ERC1967/ERC1967UpgradeUpgradeable.sol#24) is never used and should be removed
ERC1967UpgradeUpgradeable._changeAdmin(address) (node_modules/@openzeppelin/contracts-upgradeable/proxy/ERC1967/ERC1967UpgradeUpgradeable.sol#133-136) is never used and should be removed
ERC1967UpgradeUpgradeable._getAdmin() (node_modules/@openzeppelin/contracts-upgradeable/proxy/ERC1967/ERC1967UpgradeUpgradeable.sol#116-118) is never used and should be removed
ERC1967UpgradeUpgradeable._getBeacon() (node_modules/@openzeppelin/contracts-upgradeable/proxy/ERC1967/ERC1967UpgradeUpgradeable.sol#148-150) is never used and should be removed
ERC1967UpgradeUpgradeable._setAdmin(address) (node_modules/@openzeppelin/contracts-upgradeable/proxy/ERC1967/ERC1967UpgradeUpgradeable.sol#123-126) is never used and should be removed
ERC1967UpgradeUpgradeable._setBeacon(address) (node_modules/@openzeppelin/contracts-upgradeable/proxy/ERC1967/ERC1967UpgradeUpgradeable.sol#155-162) is never used and should be removed
ERC1967UpgradeUpgradeable._upgradeBeaconToAndCall(address,bytes,bool) (node_modules/@openzeppelin/contracts-upgradeable/proxy/ERC1967/ERC1967UpgradeUpgradeable.sol#170-178) is never used and should be removed
Initializable._getInitializedVersion() (node_modules/@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol#159-161) is never used and should be removed
Initializable._isInitializing() (node_modules/@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol#166-168) is never used and should be removed
Ownable2StepUpgradeable.__Ownable2Step_init_unchained() (node_modules/@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol#25) is never used and should be removed
OwnableUpgradeable.__Ownable_init() (node_modules/@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol#29-31) is never used and should be removed
StorageSlotUpgradeable.getBytes32Slot(bytes32) (node_modules/@openzeppelin/contracts-upgradeable/utils/StorageSlotUpgradeable.sol#72-77) is never used and should be removed
StorageSlotUpgradeable.getUint256Slot(bytes32) (node_modules/@openzeppelin/contracts-upgradeable/utils/StorageSlotUpgradeable.sol#82-87) is never used and should be removed
UUPSUpgradeable.__UUPSUpgradeable_init_unchained() (node_modules/@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol#29) is never used and should be removed
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#dead-code
INFO:Detectors:
Pragma version^0.8.0 (node_modules/@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol#4) allows old versions
Pragma version^0.8.0 (node_modules/@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol#4) allows old versions
Pragma version^0.8.0 (node_modules/@openzeppelin/contracts-upgradeable/interfaces/IERC1967Upgradeable.sol#4) allows old versions
Pragma version^0.8.0 (node_modules/@openzeppelin/contracts-upgradeable/interfaces/draft-IERC1822Upgradeable.sol#4) allows old versions
Pragma version^0.8.2 (node_modules/@openzeppelin/contracts-upgradeable/proxy/ERC1967/ERC1967UpgradeUpgradeable.sol#4) allows old versions
Pragma version^0.8.0 (node_modules/@openzeppelin/contracts-upgradeable/proxy/beacon/IBeaconUpgradeable.sol#4) allows old versions
Pragma version^0.8.2 (node_modules/@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol#4) allows old versions
Pragma version^0.8.0 (node_modules/@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol#4) allows old versions
Pragma version^0.8.0 (node_modules/@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol#4) allows old versions
Pragma version^0.8.1 (node_modules/@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol#4) allows old versions
Pragma version^0.8.0 (node_modules/@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol#4) allows old versions
Pragma version^0.8.0 (node_modules/@openzeppelin/contracts-upgradeable/utils/StorageSlotUpgradeable.sol#4) allows old versions
Pragma version0.8.19 (contracts/EscrowMigrator.sol#2) necessitates a version too recent to be trusted. Consider deploying with 0.8.18.
Pragma version>=0.5.0<0.9.0 (contracts/interfaces/IERC20.sol#2) is too complex
Pragma version0.8.19 (contracts/interfaces/IEscrowMigrator.sol#2) necessitates a version too recent to be trusted. Consider deploying with 0.8.18.
Pragma version^0.8.0 (contracts/interfaces/IKwenta.sol#3) allows old versions
Pragma version^0.8.0 (contracts/interfaces/IRewardEscrow.sol#2) allows old versions
Pragma version0.8.19 (contracts/interfaces/IRewardEscrowV2.sol#2) necessitates a version too recent to be trusted. Consider deploying with 0.8.18.
Pragma version^0.8.0 (contracts/interfaces/IStakingRewards.sol#2) allows old versions
Pragma version0.8.19 (contracts/interfaces/IStakingRewardsIntegrator.sol#2) necessitates a version too recent to be trusted. Consider deploying with 0.8.18.
Pragma version0.8.19 (contracts/interfaces/IStakingRewardsV2.sol#2) necessitates a version too recent to be trusted. Consider deploying with 0.8.18.
solc-0.8.19 is not recommended for deployment
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#incorrect-versions-of-solidity
INFO:Detectors:
Low level call in ERC1967UpgradeUpgradeable._functionDelegateCall(address,bytes) (node_modules/@openzeppelin/contracts-upgradeable/proxy/ERC1967/ERC1967UpgradeUpgradeable.sol#186-197):
	- (success,returndata) = target.delegatecall(data) (node_modules/@openzeppelin/contracts-upgradeable/proxy/ERC1967/ERC1967UpgradeUpgradeable.sol#193)
Low level call in AddressUpgradeable.sendValue(address,uint256) (node_modules/@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol#60-65):
	- (success) = recipient.call{value: amount}() (node_modules/@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol#63)
Low level call in AddressUpgradeable.functionCallWithValue(address,bytes,uint256,string) (node_modules/@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol#127-136):
	- (success,returndata) = target.call{value: value}(data) (node_modules/@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol#134)
Low level call in AddressUpgradeable.functionStaticCall(address,bytes,string) (node_modules/@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol#158-165):
	- (success,returndata) = target.staticcall(data) (node_modules/@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol#163)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#low-level-calls
INFO:Detectors:
Function Ownable2StepUpgradeable.__Ownable2Step_init() (node_modules/@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol#21-23) is not in mixedCase
Function Ownable2StepUpgradeable.__Ownable2Step_init_unchained() (node_modules/@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol#25) is not in mixedCase
Variable Ownable2StepUpgradeable.__gap (node_modules/@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol#70) is not in mixedCase
Function OwnableUpgradeable.__Ownable_init() (node_modules/@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol#29-31) is not in mixedCase
Function OwnableUpgradeable.__Ownable_init_unchained() (node_modules/@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol#33-35) is not in mixedCase
Variable OwnableUpgradeable.__gap (node_modules/@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol#94) is not in mixedCase
Function ERC1967UpgradeUpgradeable.__ERC1967Upgrade_init() (node_modules/@openzeppelin/contracts-upgradeable/proxy/ERC1967/ERC1967UpgradeUpgradeable.sol#22) is not in mixedCase
Function ERC1967UpgradeUpgradeable.__ERC1967Upgrade_init_unchained() (node_modules/@openzeppelin/contracts-upgradeable/proxy/ERC1967/ERC1967UpgradeUpgradeable.sol#24) is not in mixedCase
Variable ERC1967UpgradeUpgradeable.__gap (node_modules/@openzeppelin/contracts-upgradeable/proxy/ERC1967/ERC1967UpgradeUpgradeable.sol#204) is not in mixedCase
Function UUPSUpgradeable.__UUPSUpgradeable_init() (node_modules/@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol#27) is not in mixedCase
Function UUPSUpgradeable.__UUPSUpgradeable_init_unchained() (node_modules/@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol#29) is not in mixedCase
Variable UUPSUpgradeable.__self (node_modules/@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol#32) is not in mixedCase
Variable UUPSUpgradeable.__gap (node_modules/@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol#115) is not in mixedCase
Function PausableUpgradeable.__Pausable_init() (node_modules/@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol#34-36) is not in mixedCase
Function PausableUpgradeable.__Pausable_init_unchained() (node_modules/@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol#38-40) is not in mixedCase
Variable PausableUpgradeable.__gap (node_modules/@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol#116) is not in mixedCase
Function ContextUpgradeable.__Context_init() (node_modules/@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol#19) is not in mixedCase
Function ContextUpgradeable.__Context_init_unchained() (node_modules/@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol#21) is not in mixedCase
Variable ContextUpgradeable.__gap (node_modules/@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol#36) is not in mixedCase
Parameter EscrowMigrator.initialize(address)._contractOwner (contracts/EscrowMigrator.sol#113) is not in mixedCase
Parameter EscrowMigrator.registerEntries(uint256[])._entryIDs (contracts/EscrowMigrator.sol#186) is not in mixedCase
Parameter EscrowMigrator.migrateEntries(address,uint256[])._entryIDs (contracts/EscrowMigrator.sol#248) is not in mixedCase
Parameter EscrowMigrator.registerIntegratorEntries(address,uint256[])._integrator (contracts/EscrowMigrator.sol#336) is not in mixedCase
Parameter EscrowMigrator.registerIntegratorEntries(address,uint256[])._entryIDs (contracts/EscrowMigrator.sol#336) is not in mixedCase
Parameter EscrowMigrator.migrateIntegratorEntries(address,address,uint256[])._integrator (contracts/EscrowMigrator.sol#344) is not in mixedCase
Parameter EscrowMigrator.migrateIntegratorEntries(address,address,uint256[])._entryIDs (contracts/EscrowMigrator.sol#344) is not in mixedCase
Function IRewardEscrowV2.MINIMUM_EARLY_VESTING_FEE() (contracts/interfaces/IRewardEscrowV2.sol#67) is not in mixedCase
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#conformance-to-solidity-naming-conventions
INFO:Detectors:
Variable EscrowMigrator.constructor(address,address,address,address,address)._rewardEscrowV1 (contracts/EscrowMigrator.sol#94) is too similar to EscrowMigrator.constructor(address,address,address,address,address)._rewardEscrowV2 (contracts/EscrowMigrator.sol#95)
Variable EscrowMigrator.constructor(address,address,address,address,address)._stakingRewardsV1 (contracts/EscrowMigrator.sol#96) is too similar to EscrowMigrator.constructor(address,address,address,address,address)._stakingRewardsV2 (contracts/EscrowMigrator.sol#97)
Variable EscrowMigrator.rewardEscrowV1 (contracts/EscrowMigrator.sol#51) is too similar to EscrowMigrator.rewardEscrowV2 (contracts/EscrowMigrator.sol#55)
Variable EscrowMigrator.stakingRewardsV1 (contracts/EscrowMigrator.sol#59) is too similar to EscrowMigrator.stakingRewardsV2 (contracts/EscrowMigrator.sol#63)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#variable-names-too-similar
INFO:Slither:./contracts/EscrowMigrator.sol analyzed (22 contracts with 85 detectors), 100 result(s) found
```
