# Vertigo-RS

Smart contracts I am testing:
- [NFTStaking](../week2/src/trio/NFTStaking.sol)
- [RoyaltyNFT](../week2/src/trio/RoyaltyNFT.sol)
- [NFTRewards](../week2/src/trio/NFTRewards.sol)

I have ensured the tests for these contracts have 100% line and branch coverage.

Then I ran:
```bash
python <path-to-vertigo-rs>/vertigo.py run
```

Results:
```
Mutations:

[+] Survivors
Mutation:
    File: /Users/thomasharper/rare_skills/rareskills-work/week2/src/trio/NFTRewards.sol
    Line nr: 18
    Result: Lived
    Original line:
             function setNFTStaking(address _nftStaking) external onlyOwner {

    Mutated line:
             function setNFTStaking(address _nftStaking) external  {

Mutation:
    File: /Users/thomasharper/rare_skills/rareskills-work/week2/src/trio/NFTRewards.sol
    Line nr: 22
    Result: Lived
    Original line:
             function mint(address to, uint256 amount) external onlyNFTStaking {

    Mutated line:
             function mint(address to, uint256 amount) external  {

Mutation:
    File: /Users/thomasharper/rare_skills/rareskills-work/week2/src/trio/RoyaltyNFT.sol
    Line nr: 25
    Result: Lived
    Original line:
                 assert(_reservedTokens < 20);

    Mutated line:
                 assert(_reservedTokens <= 20);

Mutation:
    File: /Users/thomasharper/rare_skills/rareskills-work/week2/src/trio/RoyaltyNFT.sol
    Line nr: 25
    Result: Lived
    Original line:
                 assert(_reservedTokens < 20);

    Mutated line:


Mutation:
    File: /Users/thomasharper/rare_skills/rareskills-work/week2/src/trio/RoyaltyNFT.sol
    Line nr: 65
    Result: Lived
    Original line:
                 _mint(msg.sender, index);

    Mutated line:


Mutation:
    File: /Users/thomasharper/rare_skills/rareskills-work/week2/src/trio/RoyaltyNFT.sol
    Line nr: 23
    Result: Lived
    Original line:
             ) ERC721("RoyaltyNFT", "RNFT") Ownable2Step() {

    Mutated line:
             ) ERC721("RoyaltyNFT", "RNFT")  {

Mutation:
    File: /Users/thomasharper/rare_skills/rareskills-work/week2/src/trio/RoyaltyNFT.sol
    Line nr: 31
    Result: Lived
    Original line:
             function withdrawFunds(address to) external onlyOwner {

    Mutated line:
             function withdrawFunds(address to) external  {
```

## Summary

- Total findings: 15 surviving mutants
- Positives: 7
- False positives: 1 - sort of (it was kind of useful though - see valid finding 6.)

### Valid findings

1. Modifier not tested - `function setNFTStaking(address _nftStaking) external onlyOwner {`
   - Great find!
2. Modifier not tested - `function mint(address to, uint256 amount) external onlyNFTStaking {`
   - Great find!
3. Less than edge case not tested - `assert(_reservedTokens < 20);` - `<` vs `<=`
   - After looking at this decided (though it doesn't effect security) in this instance `<=` is better
   - Great find!
4. Line can be deleted - `assert(_reservedTokens < 20);`
   - Fixed by the last one, but still a good find!
5. Line can be deleted - `_mint(msg.sender, index);`
   - Fantastic find! Shows weakness of the tests.
6. Inherited functionality not tested - `) ERC721("RoyaltyNFT", "RNFT") Ownable2Step() {`
   - Good find in that it made me test the inherited functionality
   - Bad find in the sene that you can remove `Ownable2Step()` and it still works the same as there are no constructor args
7. Modifier not tested - `function withdrawFunds(address to) external onlyOwner {`
   - Good find

## Notes

This was very revealing about what `forge coverage` does not catch!

Things `forge coverage` doesn't catch:
- modifiers
- branches in the constructor
- inherited functionality!

Overall I am very impressed by mutation testing, it was very informative about the test coverage for this project, which although it had 100% line and branch coverage, had a lot of untested logic.

It just shows how misleading coverage reports can be.

I had earlier tried to run `vertigo-rs` on work codebase, and basically gave up after leaving it running for about 5 hours, as it was expected to take well over 24 hours.

But having got these very useful results on this kind of toy project, I may do some more work at work to get it running properly.

That might mean isolating smaller parts of the codebase and testing just those in isolation using the mutation tester, or spinning up a server to run it for me.

One other thing to note is that I didn't put much work into thoroughly testing the NFT Staking system, whereas at work, as real money is on the line, there is much more thorough testing done, so it would be interesting to see if it still produces useful results on a more thoroughly tested codebase.

Either way, I am very impressed by mutation testing amd vertigo-rs, and think this is a very valuable approach to use.
