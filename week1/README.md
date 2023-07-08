# Week 1 Work

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

