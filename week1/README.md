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

## TODO

- Add natspec
