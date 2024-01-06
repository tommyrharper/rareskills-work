# Week 2 Upgradeable Questions

## When a contract calls another call via call, delegatecall, or staticcall, how is information passed between them? Where is this data stored?

At the level of the EVM, when message call is made, an EVM instance is recursively created within the EMV. This new EVM instance is spawned with all the necessary data and context available to it.

## If a proxy calls an implementation, and the implementation self-destructs in the function that gets called, what happens?

If the proxy has delegate called the implementation, and the implementation self-destructs, then the proxy will be self destructed.

## If a proxy calls an empty address or an implementation that was previously self-destructed, what happens?

The transaction will succeed but do nothing and return nothing.

## If a user calls a proxy makes a delegatecall to A, and A makes a regular call to B, from A's perspective, who is msg.sender? from B's perspective, who is msg.sender? From the proxy's perspective, who is msg.sender?

- From the proxy's perspective, `msg.sender` is the user.
- From `A`'s perspective, `msg.sender` is the user.
- From `B`'s perspective, `msg.sender` is the proxy.

## If a proxy makes a delegatecall to A, and A does address(this).balance, whose balance is returned, the proxy's or A?

The proxies balance is returned.

## If a proxy makes a delegatecall to A, and A calls codesize, is codesize the size of the proxy or A?

- If the opcode used is `CODESIZE` then the value returned will be the codesize of `A`.
- If the opcode used is `EXTCODESIZE` and the address passed in is from the `OPCODE` address, then the codesize will the size of the proxy.
  - This would happen with this code: `address(this).code.length` based on the current solidity compiler behaviour.

## If a delegatecall is made to a function that reverts, what does the delegatecall do?

It returns `0` onto the stack.

## Under what conditions does the Openzeppelin Proxy.sol overwrite the free memory pointer? Why is it safe to do this?

It copies the return data from the `delegatecall` into memory slot `0`, overwriting the free memory pointer if the return data is more than 64 bytes.

```solidity
// Copy the returned data.
returndatacopy(0, 0, returndatasize())
```

This is safe because at this point the remaining code to execute does not use the free memory pointer, it simply returns the return data or reverts:

```solidity
switch result
// delegatecall returns 0 on error.
case 0 {
    revert(0, returndatasize())
}
default {
    return(0, returndatasize())
}
```

## If a delegatecall is made to a function that reads from an immutable variable, what will the value be?

If the immutable value is defined in the implementation contract, then the value will simply be the immutable value stored in the implementation contract bytecode on contract creation.

## If a delegatecall is made to a contract that makes a delegatecall to another contract, who is msg.sender in the proxy, the first contract, and the second contract?

The `msg.sender` in all situations is the `EOA` who initiated the transaction.
