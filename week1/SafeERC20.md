# SafeERC20

SafeERC20 was developed to handle a specific problem with ERC20 tokens.

Different implementations of ERC20 tend to do one of two things when handling reverting transactions:
1. Revert the transaction
2. Return false if the transaction fails

Unfortunately this can cause problems if a smart contract developer assumes a transaction will revert if it fails and doesn't check if the return value is false, if the ERC20 token takes the second approach.

The simple solution to this is to wrap the token in OpenZeppelin's SafeERC20 or similar code. This ensure the transaction will revert if it returns false. So you no longer need to check if the return value is false and revert, you just know whenever you make a transaction if it fails it will revert.
