# Week 21

### Exercise 0

- [x] [EIP 712 Delimiter Q&A](./eip-721-delimiter.md)

## Exercise 1

- [x] Hack `DoubleTake` in Solidity Riddles
  - https://github.com/RareSkills/solidity-riddles/blob/main/contracts/DoubleTake.sol
  - [My Solution](./https://github.com/tommyrharper/solidity-riddles/blob/main/test/DoubleTake.js)

### Exercise 2

- [x] Find a message and signature that will [hack this](./exercise-2/src/Week22Exercise2.sol)
  - [My solution](./exercise-2/test/Week22Exercise2.t.sol)

### Exercise 3

- [x] [This contract](./exercise-3/src/Week22Exercise3.sol) has a medium severity weakness.
  - [My solution](./exercise-3/test/Week22Exercise3.t.sol)

### Exercise 4

- [x] Hack [this contract](./exercise-4/src/Week22Exercise4.sol). This will be more challenging than the earlier ones.
  - [My Solution](./exercise-4/test/Week22Exercise4.t.sol)

## Questions

- [ ] For the EIP 712 delimiter, when would a salt actually be necessary?
- [ ] For exercise 2, did I do the right thing?
- [ ] For exercise 4, was a way to directly define my `hashStruct` without using `abi.encodePacked`, but instead just define `bytes memory hashStruct` directly? [See here](./exercise-4/test/Week22Exercise4.t.sol)
