# OpenSea Events

OpenSea can tell exactly who owns which NFT even if they are not "Enumerable" contracts as it can just look at the events data emitted by the ERC721 contracts.

Every time an NFT is minted, burned or transferred an event is emitted:
```solidity
event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
```

If I was building an NFT marketplace I would use "The Graph" and build a subgraph that indexes all the events emitted by the ERC721 contracts I am interested in.

Then my frontend could consume the GraphQL API provided by my subgraph to provide users with all the data they need.

In fact I probably would have to write very little code as I am sure there are already open source implementations of this.
