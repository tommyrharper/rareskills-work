# Proxy Questions and Answers

## **Question 1:** The OZ upgrade tool for hardhat defends against 6 kinds of mistakes. What are they and why do they matter?

1. Storage collisions - when you write a new storage variable to an old storage slot. This will likely brick your smart contract.
2. Using a constructor - state variables set in a constructor on a proxy will not be accessible by the proxy.
3. Checks you are not using `selfdestruct` in your implementation which could brick your contract.
4. Checks you are not missing your public `upgradeTo` function so you do not accidentally make your contract immutable.
5. Checks you are not using `immutable` variables as proxy implementations (according to OZ) don't have constructors, and we don't want to force every proxy to use the same value for an immutable variable for a given implementation. I disagree with OZ on this, in my opinion `immutable` variables are safe to use with proxies and I use them frequently. But it is necessary to understand how they work, so perhaps OZ is just going on the side of caution here for devs that don't understand how immutable variables work at the EVM level.
6. Checks you are not using `delegatecall`, incase an attacker was able to get the implementation to delegate call a contract with a `selfdestruct` opcode, destroying your proxy.

Here is how to disable some of these checks:
```solidity
/// @custom:oz-upgrades-unsafe-allow state-variable-immutable
/// @custom:oz-upgrades-unsafe-allow state-variable-assignment
/// @custom:oz-upgrades-unsafe-allow external-library-linking
/// @custom:oz-upgrades-unsafe-allow constructor
/// @custom:oz-upgrades-unsafe-allow delegatecall
/// @custom:oz-upgrades-unsafe-allow selfdestruct
```

## **Question 2:** What is a beacon proxy used for?


## **********************Question 3:********************** Why does the openzeppelin upgradeable tool insert something like `uint256[50] private __gap;` inside the contracts? To see it, create an upgradeable smart contract that has a parent contract and look in the parent.


## **Question 4:** What is the difference between initializing the proxy and initializing the implementation? Do you need to do both? When do they need to be done?


## **Question 5:** What is the use for the [reinitializer](https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/master/contracts/proxy/utils/Initializable.sol#L119)? Provide a minimal example of proper use in Solidity


