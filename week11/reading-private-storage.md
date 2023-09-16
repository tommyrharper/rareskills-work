# Reading from private storage

## Using web3 js

```js
await web3.eth.getStorageAt(contractAddress, slot);
```

## Using ethers.js

```js
await ethers.provider.getStorageAt(contract_address, 0);
```

## Using an ethers.js script

```js
const {ethers,utils } = require("ethers");
const rpc_url = "https://eth.g.alchemy.com/v2/abcd" //add your rpc_url here
const provider = new ethers.providers.JsonRpcProvider(rpc_url)

async function start() {
  const contract_address = //add contract address here
  const slot = // add the storage slot of contract you want to access
  const data = await provider.getStorageAt(contract_address, slot) 
  console.log("Private Data :", data)
}

start()
```

## Using Slither

```bash
slither-read-storage <contract_address> --variable-name <variable name> --rpc-url $rpc_url --value
```
