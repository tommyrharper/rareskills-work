object "ERC1155" {
    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/
    code {
      // return the runtime code
      datacopy(0, dataoffset("Runtime"), datasize("Runtime"))
      return(0, datasize("Runtime"))
    }

    /*//////////////////////////////////////////////////////////////
                                RUNTIME
    //////////////////////////////////////////////////////////////*/
    object "Runtime" {

      /*//////////////////////////////////////////////////////////////
                              MEMORY LAYOUT
      //////////////////////////////////////////////////////////////*/

      // 0x00 - 0x3f (64 bytes): scratch space for hashing methods
      // 0x40 - 0x5f (32 bytes): currently allocated memory size (aka. free memory pointer)
      // 0x60 - 0x7f (32 bytes): zero slot

      code {
        mstore(0x40, 0x80)

        switch getSelector()
        case 0x731133e9 /* mint(address,uint256,uint256,bytes) */ {
          _mint(decodeAddress(0), decodeUint(1), decodeUint(2))
        }
        case 0x00fdd58e /* "balanceOf(address,uint256)" */ {
          returnUint(balanceOf(decodeAddress(0), decodeUint(1)))
        }
        default {
          revert(0, 0)
        }

        /*//////////////////////////////////////////////////////////////
                              MUTATIVE FUNCTIONS
        //////////////////////////////////////////////////////////////*/

        function _mint(account, id, amount) {
          let offset := getFreeMemoryPointer()
          storeInMemory(account)
          storeInMemory(id)
          let storageLocation := keccak256(offset, 0x40)
          sstore(storageLocation, amount)
        }

        function callReceiver(account) {
          let size := extcodesize(account)
          if gt(size, 0) {
            // onERC1155Received(address,address,uint256,uint256,bytes)
            let onERC1155ReceivedSelector := 0xf23a6e6100000000000000000000000000000000000000000000000000000000

            // abi encode arguments


            // call(g, a, v, in, insize, out, outsize)
            let argsOffset := 0
            let argsBytes := 0
            let returnOffset := 0
            let returnBytes := 0
            let success := call(
              gas(), account, 0, argsOffset, argsBytes, returnOffset, returnBytes
            )
          }
        }

        /*//////////////////////////////////////////////////////////////
                                VIEW FUNCTIONS
        //////////////////////////////////////////////////////////////*/

        function balanceOf(account, id) -> b {
          let offset := getFreeMemoryPointer()
          storeInMemory(account)
          storeInMemory(id)
          b := sload(keccak256(offset, 0x40))
        }

        /*//////////////////////////////////////////////////////////////
                                  ABI DECODING
        //////////////////////////////////////////////////////////////*/

        function getSelector() -> s {
          // copy first 4 bytes from calldata
          // we do this by loading 32 bytes from calldata starting at position 0
          // then we shift right by 28 bytes (= 8 * 28 = 224 bits = 0xE0 bits)
          s := shr(0xE0, calldataload(0))
        }

        function decodeAddress(offset) -> v {
          v := decodeUint(offset)
          // TODO: check is 20 bytes
          // TODO: check is not zero address
        }

        function decodeUint(offset) -> v {
          let pos := add(4, mul(offset, 0x20))
          v := calldataload(pos)
        }

        /*//////////////////////////////////////////////////////////////
                                    ENCODING
        //////////////////////////////////////////////////////////////*/

        function returnUint(v) {
          mstore(0, v)
          return(0, 0x20)
        }

        /*//////////////////////////////////////////////////////////////
                              MEMORY MANAGEMENT
        //////////////////////////////////////////////////////////////*/

        function storeInMemory(value) {
          let offset := getFreeMemoryPointer()
          mstore(offset, value)
          setFreeMemoryPointer(add(offset, 0x20))
        }

        function getFreeMemoryPointer() -> p {
          p := mload(0x40)
        }

        function setFreeMemoryPointer(newPos) {
          mstore(0x40, newPos)
        }
      }
    }
  }