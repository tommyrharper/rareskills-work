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
          mstore(0, account)
          mstore(1, id)
          let storageLocation := keccak256(0, 0x40)
          sstore(storageLocation, amount)
        }

        /*//////////////////////////////////////////////////////////////
                                VIEW FUNCTIONS
        //////////////////////////////////////////////////////////////*/

        function balanceOf(account, id) -> b {
          mstore(0, account)
          mstore(1, id)
          b := sload(keccak256(0, 0x40))
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
      }
    }
  }