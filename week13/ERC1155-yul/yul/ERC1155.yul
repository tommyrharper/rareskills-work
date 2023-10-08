object "ERC1155" {
    // CONSTRUCTOR
    code {
      // return the runtime code
      datacopy(0, dataoffset("Runtime"), datasize("Runtime"))
      return(0, datasize("Runtime"))
    }

    // RUNTIME
    object "Runtime" {
      code {
        switch getSelector()
        case 0x731133e9 /* mint(address,uint256,uint256,bytes) */ {

        }
        case 0x00fdd58e /* "balanceOf(address,uint256)" */ {
          let account := decodeAddress(0)
          let id := decodeUint(1)

          returnUint(balanceOf(decodeAddress(0), decodeUint(1)))
        }
        default {
          revert(0, 0)
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

        function returnUint(v) {
          mstore(0, v)
          return(0, 0x20)
        }

        function balanceOf(account, id) -> b {
          mstore(0, account)
          mstore(1, id)
          b := sload(keccak256(0, 64))
        }

        function getSelector() -> s {
          // copy first 4 bytes from calldata
          // we do this by loading 32 bytes from calldata starting at position 0
          // then we shift right by 28 bytes (= 8 * 28 = 224 bits = 0xE0 bits)
          s := shr(0xE0, calldataload(0))
        }
      }

    }
  }