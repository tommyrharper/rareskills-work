# EIP 712 Delimiter

## What pieces of information go in to an EIP 712 delimiter, and what could go wrong if those were omitted?

I presume by delimiter, we are referring to the domain separator.

In this we hash the `EIP712Domain`, which contains the following data:
- `string name` the user readable name of signing domain
- `string version` the current major version of the signing domain
- `uint256 chainId` the EIP-155 chain id
- `address verifyingContract` the address of the contract that will verify the signature
- `bytes32 salt` an disambiguating salt for the protocol

If this data was omitted, it would open up the door to a number of potential issues/vulnerabilities.

The ultimate idea is to ensure that any given signature only ever works with the intended contract. If we just hashed and signed the typed data, then that signature could be used with any other contract that uses the same data.

So by specifying the `name` and `verifyingContract` we can single out a given contract. The version allows us to upgrade, breaking old signatures.

The `chainId` is essential for preventing replay attacks when deploying on multiple chains (or this implicitly occuring due to hard-forks).

The `salt` can be used as a last resort to further disambiguate the domain.
