# Week 5 - Static Analysis and Mutation Testing

## Markdown Document 1 - Static Analysis

### Markdown document 1.1 - Run Slither on a Codebase

- [Exercise 1.1](./slither.md)

### Markdown document 1.2 - Run MythX on a Codebase

- [Exercise1.2](./mythx.md)

### Notes

Both of these resulted in 100% false positives. MythX was new to me, but I have used slither frequently, but never found it particularly useful.

I think this reflects my approach to smart contract development - I am reasonably well trained in identifying and fixing common, wellknown hacks and issues in smart contracts, and I usually would usually follow the following pattern:
- TDD code with unit tests and fuzz tests
- Think rigorously along the way about attack vectors
- Write invariant tests
- Try to forget everything about the system and look at it with fresh eyes, from the perspective of an attacker and try to find vulnerabilities
- Fix any issues that are found
- Meticulously format and comment code
- Apply gas optimizations
- Then I run `slither` as a sanity check for anything obvious I might have missed. At this point I have not come across a scenario yet where slither has been able to find anything useful for me that I haven't already noticed.

Perhaps if I used slither earlier in the process, it might be more useful. For me it is just a sanity check, and hasn't been a massively useful tool.

With MythX it is harder to give a fair assessment, as I have only used it once. However in this instance it didn't find anything useful.
