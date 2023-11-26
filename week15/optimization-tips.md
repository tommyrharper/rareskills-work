# Optimization Tips

## Top Tips

1. Most important: avoid zero to one storage writes where possible
2. Cache storage variables: write and read storage variables exactly once
3. Pack related variables
4. Pack structs
5. Keep strings smaller than 32 bytes
6. Variables that are never updated should be immutable or constant
7. Using mappings instead of arrays to avoid length checks
8. Using unsafeAccess on arrays to avoid redundant length checks
9. Use bitmaps instead of bools when a significant amount of booleans are used
10. Use SSTORE2 or SSTORE3 to store a lot of data
11. Use storage pointers instead of memory where appropriate
12. Avoid having ERC20 token balances go to zero, always keep a small amount
13. Count from n to zero instead of counting from zero to n
14. Timestamps and block numbers do not need to be uint256 

## Deployment Optimizations

1. Use the account nonce to predict the addresses of interdependent smart contracts thereby avoiding storage variables and address setter functions
2. Make constructors payable
3. Deployment size can be reduced by optimizing the IPFS hash to have more zeros (or using the --no-cbor-metadata compiler option)
4. Use selfdestruct in the constructor if the contract is one-time use
5. Understand the trade-offs when choosing between internal functions and modifiers
6. Use clones or metaproxies when deploying very similar smart contracts that are not called frequently
7. Admin functions can be payable
8. Custom errors are (usually) smaller than require statements
9. Use existing create2 factories instead of deploying your own

## Design Patterns

1. Use transfer hooks for tokens instead of initiating a transfer from the destination smart contract
2. Use fallback or receive instead of deposit() when transferring Ether
3. Use ERC2930 access list transactions when making cross-contract calls to pre-warm storage slots
4. Cache calls to external contracts where it makes sense (like caching return data from chainlink oracle)
5. Implement multicall in router-like contracts
6. Avoid contract calls by making the architecture monolithic

## Calldata Optimizations

1. Use vanity addresses (safely!)
2. Avoid signed integers in calldata if possible
3. Calldata is (usually) cheaper than memory
4. Consider packing calldata, especially on an L2

## Assembly Tricks

1. Using assembly to revert with an error message
2. Calling functions via interface incurs memory expansion costs, so use assembly to re-use data already in memory
3. Common math operations, like min and max have gas efficient alternatives
4. Use SUB or XOR instead of ISZERO(EQ()) to check for inequality (more efficient in certain scenarios)
5. Use inline assembly to check for address(0)
6. selfbalance is cheaper than address(this).balance (more efficient in certain scenarios)
7. Use assembly to perform operations on data of size 96 bytes or less: hashing and unindexed data in events
8. Use assembly to reuse memory space when making more than one external call.
9. Use assembly to reuse memory space when creating more than one contract.
10. Test if a number is even or odd by checking the last bit instead of using a modulo operator

## Solidity Compiler Related

1. Prefer strict inequalities over non-strict inequalities, but test both alternatives
2. Split require statements that have boolean expressions
3. Split revert statements
4. Always use Named Returns
5. Invert if-else statements that have a negation
6. Use ++i instead of i++ to increment
7. Use unchecked math where appropriate
8. Write gas-optimal for-loops
9. Do-While loops are cheaper than for loops
10. Avoid Unnecessary Variable Casting, variables smaller than uint256 (including boolean and address) are less efficient unless packed
11. Short-circuit booleans
12. Don’t make variables public unless it is necessary to do so
13. Prefer very large values for the optimizer
14. Heavily used functions should have optimal names
15. Bitshifting is cheaper than multiplying or dividing by a power of two
16. It is sometimes cheaper to cache calldata
17. Use branchless algorithms as a replacement for conditionals and loops
18. Internal functions only used once can be inlined to save gas
19. Compare array equality and string equality by hashing them if they are longer than 32 bytes
20. Use lookup tables when computing powers and logarithms
Precompiled contracts may be useful for some multiplication or memory operations.

## Dangerous Techniques

1. Use gasprice() or msg.value to pass information
2. Manipulate environment variables like coinbase() or block.number if the tests allow it
3. Use gasleft() to branch decisions at key points
4. Use send() to move ether, but don’t check for success
5. Make all functions payable
6. External library jumping
7. Append bytecode to the end of the contract to create a highly optimized subroutine
