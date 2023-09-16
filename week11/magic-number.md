# Magic Number

- https://ethernaut.openzeppelin.com/level/0xFe18db6501719Ab506683656AAf2F80243F8D0c0

In order to complete this level I need deploy a contract that returns 42.

This is such a contract:

```
604260005260206000F3
```

In order to simplify the process, instead of writing the contract creation code to create this contract, I simply used the following solidity code:

```solidity
pragma solidity ^0.5.5;

contract DeployBytecode {
    
    // Create contract from bytecode
    function deployBytecode(bytes memory bytecode) public returns (address) {
        address retval;
        assembly{
            mstore(0x0, bytecode)
            retval := create(0,0xa0, calldatasize)
        }
        return retval;
   }
}
```

This allows me to easily deploy the bytecode I need.

I deployed via remix - this is the contract address on Goerli eth: `0xc1f236ad6ab80ae62160b32366c24d947142c15b`

I then called `deployBytecode` with `0x604260005260206000F3` as the argument via remix.

This transaction failed due to the following error: `Error: contract creation code storage out of gas`.

Unfortunately I couldn't work out how to change the gas limit for my transaction on remix :(.

So I will have to try another way.

```js
await web3.eth.sendTransaction({
        from: player,
        to:"0xc1f236ad6ab80ae62160b32366c24d947142c15b",
        value: "0", 
        data: "0x02c0fba40000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000a604260005260206000f300000000000000000000000000000000000000000000",
        gas: "30000000"
    },
    function(err, transactionHash) {
        console.log("err: " + err); 
        console.log(transactionHash + " success"); 
    }
);
```

This worked but I accidentally created a contract with the following code:
```
0x0000000000000000000000000000000000000000000000000000000000000042
```

Dough!

Okay this means I need to write out the actual contract creation code.

## Contract creation code:

The same code as above, but returning the bytecode that returns 42 rather than just returning 42.

```
69 604260005260206000F3
60 00
52
60 0A
60 16
F3
```
Or:
- `69604260005260206000F3600052600A6016F3`

This time I will just do it straight with a transaction to the zero address.

```js
await web3.eth.sendTransaction({
        from: player,
        to:"0x0000000000000000000000000000000000000000",
        value: "0", 
        data: "0x69604260005260206000F3600052600A6016F3",
        gas: "30000000"
    },
    function(err, transactionHash) {
        console.log("err: " + err); 
        console.log(transactionHash + " success"); 
    }
);
```

Interestingly this did not work, it turns out the following statement is false:
- A transaction to the zero address will create a contract.

Instead the following statement is correct:
- A transaction to the `null` address will create a contract.

Hence the following transaction works:

```js
await web3.eth.sendTransaction({
        from: player,
        value: "0", 
        data: "0x69604260005260206000F3600052600A6016F3",
        gas: "30000000"
    },
    function(err, transactionHash) {
        console.log("err: " + err); 
        console.log(transactionHash + " success"); 
    }
);
```

Simply by removing the `to` address, it will now create a contract.

Here is the address my new contract: `0xE825f01581C6c3Fac23B54a0667adfB29a42576F`

And it's bytecode: `0x604260005260206000f3`

This is exactly what I wanted. I should be able to now send this address to `MagicNum` contract to complete the level.

```js
await contract.setSolver('0xE825f01581C6c3Fac23B54a0667adfB29a42576F');
```


This didn't work, lets check why:

The selector:

```bash
➜ bytes4 selector = bytes4(keccak256("whatIsTheMeaningOfLife()"));
➜ selector
Type: bytes4
└ Data: 0x650500c1
```

Hence the test transaction:

```js
await web3.eth.call({
        from: player,
        to: "0xE825f01581C6c3Fac23B54a0667adfB29a42576F",
        value: "0", 
        data: "0x650500c1",
        gas: "30000000"
    },
    function(err, transactionHash) {
        console.log("err: " + err); 
        console.log(transactionHash + " success"); 
    }
);
```

This seemed to work and returns `0x0000000000000000000000000000000000000000000000000000000000000042` which is what I anticipated.

But perhaps we want it to return `0x42`.

In which case this is the code we would want deployed: `60426000526001601FF3`

Hence our deployment code is:

```
69
60426000526001601FF3
600052600A6016F3
```

Or: `6960426000526001601FF3600052600A6016F3`

So in order to deploy that we do the following transaction:


```js
await web3.eth.sendTransaction({
        from: player,
        value: "0", 
        data: "0x6960426000526001601FF3600052600A6016F3",
        gas: "30000000"
    },
    function(err, transactionHash) {
        console.log("err: " + err); 
        console.log(transactionHash + " success"); 
    }
);
```

Our new contract is: `0x4F2931da0f316A01Fe8dcCd30eD734e587f1fE86`

Now we use that one:

```js
await contract.setSolver('0x4F2931da0f316A01Fe8dcCd30eD734e587f1fE86');
```

It just occurred to me that 42 in hex is `2A`.

Hence I should have done:
`602A60005260206000F3`
And:
```
69
602A60005260206000F3
600052600A6016F3
```
Meaning: `69602A60005260206000F3600052600A6016F3`

And so:

```js
await web3.eth.sendTransaction({
    from: player,
    value: "0", 
    data: "0x69602A60005260206000F3600052600A6016F3",
    gas: "30000000"
});
```

The new contract: `0x6d5da919a2a8d9704bf60f062ed525cd577cb026`.

There we go, done!
