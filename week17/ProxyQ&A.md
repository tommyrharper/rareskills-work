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

A beacon proxy is a way to deploy many proxies with the same implementation contract. Each proxy calls the beacon to query their implementation address, and then they delegatecall into that implementation address.

This way you can upgrade an effectively unlimited number of proxies just by changing the implementation address associated with the beacon.

## **Question 3:** Why does the openzeppelin upgradeable tool insert something like `uint256[50] private __gap;` inside the contracts? To see it, create an upgradeable smart contract that has a parent contract and look in the parent.

Because you cannot safely change the storage layout of an upgradeable contract. By leaving the gap inside inherited contracts, it means that you have some extra storage space to play with when upgrading, which offers more flexibility.

## **Question 4:** What is the difference between initializing the proxy and initializing the implementation? Do you need to do both? When do they need to be done?

Initializing the proxy will set the contract state in the proxy, which should always be done for any proxy contract that has an `initializer`. Initializing the implementation will just change the state in the implementation which shouldn't effect the proxy contract, as they do not share state. However it is generally recommended to ensure that the implementation is initialized too, to prevent a malicious actor messing with that contract. However in reality, leaving the implementation uninitialized is only dangerous if it can be used to trigger a `selfdestruct`, either directly, or via `delegatecall`. In practice, I don't think this is possible to do in most scenarios, but it is worth being aware of, to make sure this is not possible with your contract.

To be safe you can always just initialize both as standard.

## **Question 5:** What is the use for the [reinitializer](https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/master/contracts/proxy/utils/Initializable.sol#L119)? Provide a minimal example of proper use in Solidity

The `reinitializer` is a modifier that can be used to wrap initialization functions for initialization tasks (like setting initial values for new state variables) when doing upgrades. So after deploying the proxy contract for the first time and initializing it, if I want to do an upgrade and that requires further initialization, I will use the reinitializer modifier around my new `initialize` function.

Here is a solidity examples. The `v1` contract has a public state variable `a` that we want to initialize at value `5`. Then we want to upgrade and add variable `b`, but we want that initialized at value `7`.

In order to do this, we cannot reuse the `initializer` modifier, because the contract is already initialized, it won't allow us to call it. So instead we use the `reinitializer` modifier.

```solidity
Contract A_V1 is Initializable {
    uint256 public a;

    function initialize() external initializer {
        a = 5;
    }
}

contract A_V2 is A_V1 {
    uint256 public b;

    function reinitialize() external reinitializer(2) {
        b = 7;
    }
}
```
