# Week 1 Work

Thank you for taking the time to review my work.

Any feedback is greatly appreciated!

Also let me know if you have any feedback as to how I can structure this such that it easier to review.

## Markdown File 1

- Markdown File 1 - [ERC777.md](./ERC777.md)

## Markdown File 2

- Markdown File 2 - [SafeERC20.md](./SafeERC20.md)

## Solidity Contract 1

- Solidity Contract 1 - [SanctionToken.sol](./src/SanctionToken.sol)

### Notes

- Could have used OZs `AccessControl` contract for managing admin rights, but just used `Ownable` for simplicities sake.
  - Hence in this case the admin is the contract `owner`.

### Assumptions

- I assumed that there is no need to have more granular blocking - i.e. blocking a user from just sending or receiving.
  - Instead I have assumed that a blocked user can neither send nor receive tokens.
- I assumed that the `owner` of the contract is the admin and that the admin can block and unblock users.
- I have assumed that unbanning users is allowed.
- I have allowed banned users to be approved and to execute transfers using `transferFrom`
  - You could argue that this should be disallowed, but it is not clear in the spec and I think you could argue it either way.

## Solidity Contract 2

- Solidity Contract 2 - [GodToken.sol](./src/GodToken.sol)

### Notes

I have taken the approach of just overriding the `_spendAllowance` function so that contract `owner` has essentially infinite allowance for all users.

### Assumptions

- Again I have gone the route of using `Ownable` for simplicity.
  - In this case the `owner` has access to "god mode".
- God mode is does allow minting and burning of tokens.
  - This doesn't quite match up with what you might expect God mode to be, but this wasn't mentioned in the spec so I left it out.

## Solidity Contract 3

- Solidity Contract 3 - [BondingToken.sol](./src/BondingToken.sol)

### Notes

For the point "When a person sends a token to the contract with ERC1363 or ERC777, it should trigger the receive function", I was not sure exactly what is meant by this.

### Assumptions

- I have followed a very simple linear model where `token_price = total_supply`
- I have the same purchasing and selling curve.
- I have made the trading pair eth/the token.
- I haven't allowed any kind of contract owner or entity to access the reserve funds.
  - The funds are simply locked until they are redeemed by burning purchased tokens.

### Could have implemented

- It is generally better to accept a `_to` address in the `purchase` and `sell` functions.
  - This allows the user to specify the address that the tokens are sent to.
  - This is a better UX as it allows the user to specify the address that they want to receive the tokens.
    - I haven't done this just for simplicities sake.

### Sandwich attack protection

There are a number of methods to protect against sandwich attacks.

I used a `maxEntryPrice` and `minExitPrice` to protect against sandwich attacks. This allows the user to set the maximum slippage they are happy with in their trade. The advantage of this is it provides some flexibility, but it puts the burden on the user to protect themselves by using a reasonable value.

Another option would be to use a cooldown period. This would mean that the user would have to wait a certain amount of time before they could sell their tokens. This would protect against sandwich attacks, but it would also be a bit annoying for the user.

I would have implemented in this in addition to slippage limits if I had more time.

Other approaches that I didn't attempt include:
- Transaction counters
  - I don't like this approach as it is quite frustrating for users
- Gas price limits
  - I also don't like this approach as you have to keep adjusting the limits depending on network conditions
  - Also it does not protect against block constructors who can order transactions independent of gas price
- Commit-reveal strategies
  - I like the robustness of this approach, however it is quite complex and I didn't have time to implement it
  - Also I don't like the fact that users need to execute at least two transactions

## TODO

- Add natspec

### Solidity Contract 3

- Use gasleft() protection against front-running
- Use cooldown period as a protection against a sandwich attack
