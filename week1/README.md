# Week 1 Work

## Solidity Contract 1

- Solidity Contract 1 - [SanctionToken.sol](./src/SanctionToken.sol)

### Notes

- Could have used OZs `AccessControl` contract for managing admin rights, but just used `Ownable` for simplicities sake.
  - Hence in this case the admin is the contract `owner`.

### Assumptions

- I assumed that there is no need to have more granular blocking - i.e. blocking a user from just sending or receiving.
  - Instead I have assumed that a blocked user can neither send nor receive tokens.
- I assumed that the `owner` of the contract is the admin and that the admin can block and unblock users.
- I have assumed that unbanning a users is allowed.

