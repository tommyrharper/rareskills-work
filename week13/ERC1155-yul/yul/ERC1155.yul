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
        initializeFreeMemoryPointer()

        switch getSelector()
        case 0x731133e9 /* mint(address,uint256,uint256,bytes) */ {
          _mint(decodeAddress(0), decodeUint(1), decodeUint(2), decodeUint(3))
        }
        case 0xb48ab8b6 /* batchMint(address,uint256[],uint256[],bytes) */{
          batchMint(decodeAddress(0), decodeUint(1), decodeUint(2), decodeUint(3))
        }
        case 0x00fdd58e /* "balanceOf(address,uint256)" */ {
          returnUint(balanceOf(decodeAddress(0), decodeUint(1)))
        }
        case 0xf5298aca /* burn(address,uint256,uint256) */ {
          burn(decodeAddress(0), decodeUint(1), decodeUint(2))
        }
        default {
          revert(0, 0)
        }

        /*//////////////////////////////////////////////////////////////
                              MUTATIVE FUNCTIONS
        //////////////////////////////////////////////////////////////*/

        function batchMint(to, idsOffset, amountsOffset, dataOffset) {
          if iszero(to) {
              revert(0, 0)
          }

          let idsLen := decodeArrayLen(idsOffset)
          let amountsLen := decodeArrayLen(amountsOffset)

          let operator := caller()

          let idsStartPtr := add(idsOffset, 0x24)
          let amountsStartPtr := add(amountsOffset, 0x24)

          for { let i := 0 } lt(i, idsLen) { i := add(i, 1)}
          {
              let id := calldataload(add(idsStartPtr, mul(0x20, i)))
              let amount := calldataload(add(amountsStartPtr, mul(0x20, i)))
              addBalance(to, id, amount)
          }
      }

        function burn(account, id, amount) {
          subBalance(account, id, amount)
        }

        function _mint(account, id, amount, dataOffset) {
          addBalance(account, id, amount)
          checkERC1155Received(caller(), 0x0, account, id, amount, dataOffset)
        }

        function subBalance(account, id, amount) {
          let currentBalance := balanceOf(account, id)
          let offset := getFreeMemoryPointer()
          storeInMemory(account)
          storeInMemory(id)
          let storageLocation := keccak256(offset, 0x40)
          sstore(storageLocation, sub(currentBalance, amount))
        }

        function addBalance(account, id, amount) {
          let currentBalance := balanceOf(account, id)
          let offset := getFreeMemoryPointer()
          storeInMemory(account)
          storeInMemory(id)
          let storageLocation := keccak256(offset, 0x40)
          sstore(storageLocation, add(currentBalance, amount))
        }

        function checkERC1155Received(operator, from, to, id, amount, dataOffset) {
          let size := extcodesize(to)
          if gt(size, 0) {
            // onERC1155Received(address,address,uint256,uint256,bytes)
            let onERC1155ReceivedSelector := 0xf23a6e6100000000000000000000000000000000000000000000000000000000

            // abi encode arguments
            let offset := getFreeMemoryPointer()
            mstore(offset, onERC1155ReceivedSelector) // selector
            mstore(add(offset, 0x04), operator)       // operator
            mstore(add(offset, 0x24), from)           // from
            mstore(add(offset, 0x44), id)             // id
            mstore(add(offset, 0x64), amount)         // amount
            mstore(add(offset, 0x84), 0xa0)           // data

            let endPtr := copyBytesToMemory(add(offset, 0xa4), dataOffset) // Copies 'data' to memory
            setFreeMemoryPointer(endPtr)

            // call(g, a, v, in, insize, out, outsize)
            let argsOffset := offset
            let argsBytes := 0xa4
            let returnOffset := 0
            let returnBytes := 0x20
            let success := call(
              gas(), to, 0, offset, sub(endPtr, offset), 0x00, 0x04
            )
            if iszero(success) {
              revert(0, 0)
            }
          }
        }

        // TODO: find out how/why this works
        function copyBytesToMemory(mptr, dataOffset) -> newMptr {
          let dataLenOffset := add(dataOffset, 4)
          let dataLen := calldataload(dataLenOffset)

          let totalLen := add(0x20, dataLen) // dataLen+data
          let rem := mod(dataLen, 0x20)
          if rem {
              totalLen := add(totalLen, sub(0x20, rem))
          }
          calldatacopy(mptr, dataLenOffset, totalLen)

          newMptr := add(mptr, totalLen)
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

        function decodeArrayLen(offset) -> len {
          len := calldataload(add(4, offset)) // pos + selector
        }

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

        function initializeFreeMemoryPointer() {
          mstore(0x40, 0x80)
        }
      }
    }
  }