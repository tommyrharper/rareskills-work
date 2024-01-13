# Week 19

- [x] [Get EIP 712 to show in metamask with an ERC20-Permit](./eip-712-metamask/)
  - To run use the following commands:
```bash
cd eip-712-metamask
yarn
yarn chain
// open new terminal
yarn deploy
yarn start
// open http://localhost:3000/debug
// go to
```

- [x]  Gasless exchange. Given two ERC20 permit tokens, build an [order book](https://www.investopedia.com/terms/o/order-book.asp) exchange where the users never have to pay gas. They only sign approvals and orders and send those to the exchange. The order book is done off-chain. You don’t have to implmenent this exchange, just simulate its behavior
    - [Done here](./order-book)
      - Bit quick and dirty but it works and you get the gist.
