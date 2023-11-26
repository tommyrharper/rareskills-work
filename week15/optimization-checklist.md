# Optimization Tips

## Top Tips

- [ ] Most important: avoid zero to one storage writes where possible
- [ ] Cache storage variables: write and read storage variables exactly once
- [ ] Pack related variables
- [ ] Pack structs
- [ ] Keep strings smaller than 32 bytes
- [ ] Variables that are never updated should be immutable or constant
- [ ] Using mappings instead of arrays to avoid length checks
- [ ] Using unsafeAccess on arrays to avoid redundant length checks
- [ ] Use bitmaps instead of bools when a significant amount of booleans are used
- [ ] Use SSTORE2 or SSTORE3 to store a lot of data
- [ ] Use storage pointers instead of memory where appropriate
- [ ] Avoid having ERC20 token balances go to zero, always keep a small amount
- [ ] Count from n to zero instead of counting from zero to n
- [ ] Timestamps and block numbers do not need to be uint256 

## Deployment Optimizations

- [ ] Use the account nonce to predict the addresses of interdependent smart contracts thereby avoiding storage variables and address setter functions
- [ ] Make constructors payable
- [ ] Deployment size can be reduced by optimizing the IPFS hash to have more zeros (or using the --no-cbor-metadata compiler option)
- [ ] Use selfdestruct in the constructor if the contract is one-time use
- [ ] Understand the trade-offs when choosing between internal functions and modifiers
- [ ] Use clones or metaproxies when deploying very similar smart contracts that are not called frequently
- [ ] Admin functions can be payable
- [ ] Custom errors are (usually) smaller than require statements
- [ ] Use existing create2 factories instead of deploying your own

## Design Patterns

- [ ] Use transfer hooks for tokens instead of initiating a transfer from the destination smart contract
- [ ] Use fallback or receive instead of deposit() when transferring Ether
- [ ] Use ERC2930 access list transactions when making cross-contract calls to pre-warm storage slots
- [ ] Cache calls to external contracts where it makes sense (like caching return data from chainlink oracle)
- [ ] Implement multicall in router-like contracts
- [ ] Avoid contract calls by making the architecture monolithic

## Calldata Optimizations

- [ ] Use vanity addresses (safely!)
- [ ] Avoid signed integers in calldata if possible
- [ ] Calldata is (usually) cheaper than memory
- [ ] Consider packing calldata, especially on an L2

## Assembly Tricks

- [ ] Using assembly to revert with an error message
- [ ] Calling functions via interface incurs memory expansion costs, so use assembly to re-use data already in memory
- [ ] Common math operations, like min and max have gas efficient alternatives
- [ ] Use SUB or XOR instead of ISZERO(EQ()) to check for inequality (more efficient in certain scenarios)
- [ ] Use inline assembly to check for address(0)
- [ ] selfbalance is cheaper than address(this).balance (more efficient in certain scenarios)
- [ ] Use assembly to perform operations on data of size 96 bytes or less: hashing and unindexed data in events
- [ ] Use assembly to reuse memory space when making more than one external call.
- [ ] Use assembly to reuse memory space when creating more than one contract.
- [ ] Test if a number is even or odd by checking the last bit instead of using a modulo operator

## Solidity Compiler Related

- [ ] Prefer strict inequalities over non-strict inequalities, but test both alternatives
- [ ] Split require statements that have boolean expressions
- [ ] Split revert statements
- [ ] Always use Named Returns
- [ ] Invert if-else statements that have a negation
- [ ] Use ++i instead of i++ to increment
- [ ] Use unchecked math where appropriate
- [ ] Write gas-optimal for-loops
- [ ] Do-While loops are cheaper than for loops
- [ ] Avoid Unnecessary Variable Casting, variables smaller than uint256 (including boolean and address) are less efficient unless packed
- [ ] Short-circuit booleans
- [ ] Don’t make variables public unless it is necessary to do so
- [ ] Prefer very large values for the optimizer
- [ ] Heavily used functions should have optimal names
- [ ] Bitshifting is cheaper than multiplying or dividing by a power of two
- [ ] It is sometimes cheaper to cache calldata
- [ ] Use branchless algorithms as a replacement for conditionals and loops
- [ ] Internal functions only used once can be inlined to save gas
- [ ] Compare array equality and string equality by hashing them if they are longer than 32 bytes
- [ ] Use lookup tables when computing powers and logarithms
Precompiled contracts may be useful for some multiplication or memory operations.

## Dangerous Techniques

- [ ] Use gasprice() or msg.value to pass information
- [ ] Manipulate environment variables like coinbase() or block.number if the tests allow it
- [ ] Use gasleft() to branch decisions at key points
- [ ] Use send() to move ether, but don’t check for success
- [ ] Make all functions payable
- [ ] External library jumping
- [ ] Append bytecode to the end of the contract to create a highly optimized subroutine

