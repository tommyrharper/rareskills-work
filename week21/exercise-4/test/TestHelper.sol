// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";

contract TestHelpers is Test {
    enum OrderType {
        // 0: no partial fills, anyone can execute
        FULL_OPEN,
        // 1: partial fills supported, anyone can execute
        PARTIAL_OPEN,
        // 2: no partial fills, only offerer or zone can execute
        FULL_RESTRICTED,
        // 3: partial fills supported, only offerer or zone can execute
        PARTIAL_RESTRICTED,
        // 4: contract order type
        CONTRACT
    }

    enum BasicOrderRouteType {
        // 0: provide Ether (or other native token) to receive offered ERC721 item.
        ETH_TO_ERC721,
        // 1: provide Ether (or other native token) to receive offered ERC1155 item.
        ETH_TO_ERC1155,
        // 2: provide ERC20 item to receive offered ERC721 item.
        ERC20_TO_ERC721,
        // 3: provide ERC20 item to receive offered ERC1155 item.
        ERC20_TO_ERC1155,
        // 4: provide ERC721 item to receive offered ERC20 item.
        ERC721_TO_ERC20,
        // 5: provide ERC1155 item to receive offered ERC20 item.
        ERC1155_TO_ERC20
    }

    enum BasicOrderType {
        // 0: no partial fills, anyone can execute
        ETH_TO_ERC721_FULL_OPEN,
        // 1: partial fills supported, anyone can execute
        ETH_TO_ERC721_PARTIAL_OPEN,
        // 2: no partial fills, only offerer or zone can execute
        ETH_TO_ERC721_FULL_RESTRICTED,
        // 3: partial fills supported, only offerer or zone can execute
        ETH_TO_ERC721_PARTIAL_RESTRICTED,
        // 4: no partial fills, anyone can execute
        ETH_TO_ERC1155_FULL_OPEN,
        // 5: partial fills supported, anyone can execute
        ETH_TO_ERC1155_PARTIAL_OPEN,
        // 6: no partial fills, only offerer or zone can execute
        ETH_TO_ERC1155_FULL_RESTRICTED,
        // 7: partial fills supported, only offerer or zone can execute
        ETH_TO_ERC1155_PARTIAL_RESTRICTED,
        // 8: no partial fills, anyone can execute
        ERC20_TO_ERC721_FULL_OPEN,
        // 9: partial fills supported, anyone can execute
        ERC20_TO_ERC721_PARTIAL_OPEN,
        // 10: no partial fills, only offerer or zone can execute
        ERC20_TO_ERC721_FULL_RESTRICTED,
        // 11: partial fills supported, only offerer or zone can execute
        ERC20_TO_ERC721_PARTIAL_RESTRICTED,
        // 12: no partial fills, anyone can execute
        ERC20_TO_ERC1155_FULL_OPEN,
        // 13: partial fills supported, anyone can execute
        ERC20_TO_ERC1155_PARTIAL_OPEN,
        // 14: no partial fills, only offerer or zone can execute
        ERC20_TO_ERC1155_FULL_RESTRICTED,
        // 15: partial fills supported, only offerer or zone can execute
        ERC20_TO_ERC1155_PARTIAL_RESTRICTED,
        // 16: no partial fills, anyone can execute
        ERC721_TO_ERC20_FULL_OPEN,
        // 17: partial fills supported, anyone can execute
        ERC721_TO_ERC20_PARTIAL_OPEN,
        // 18: no partial fills, only offerer or zone can execute
        ERC721_TO_ERC20_FULL_RESTRICTED,
        // 19: partial fills supported, only offerer or zone can execute
        ERC721_TO_ERC20_PARTIAL_RESTRICTED,
        // 20: no partial fills, anyone can execute
        ERC1155_TO_ERC20_FULL_OPEN,
        // 21: partial fills supported, anyone can execute
        ERC1155_TO_ERC20_PARTIAL_OPEN,
        // 22: no partial fills, only offerer or zone can execute
        ERC1155_TO_ERC20_FULL_RESTRICTED,
        // 23: partial fills supported, only offerer or zone can execute
        ERC1155_TO_ERC20_PARTIAL_RESTRICTED
    }

    struct AdditionalRecipient {
        uint256 amount;
        address payable recipient;
    }

    struct BasicOrderParameters {
        // calldata offset
        address considerationToken; // 0x24
        uint256 considerationIdentifier; // 0x44
        uint256 considerationAmount; // 0x64
        address payable offerer; // 0x84
        address zone; // 0xa4
        address offerToken; // 0xc4
        uint256 offerIdentifier; // 0xe4
        uint256 offerAmount; // 0x104
        BasicOrderType basicOrderType; // 0x124
        uint256 startTime; // 0x144
        uint256 endTime; // 0x164
        bytes32 zoneHash; // 0x184
        uint256 salt; // 0x1a4
        bytes32 offererConduitKey; // 0x1c4
        bytes32 fulfillerConduitKey; // 0x1e4
        uint256 totalOriginalAdditionalRecipients; // 0x204
        AdditionalRecipient[] additionalRecipients; // 0x224
        bytes signature; // 0x244
        // Total length, excluding dynamic array data: 0x264 (580)
    }

    mapping(BasicOrderType => BasicOrderRouteType) internal _OrderToRouteType;
    mapping(BasicOrderType => OrderType) internal _BasicOrderToOrderType;


    function _validateAndFulfillBasicOrder(
        BasicOrderParameters calldata parameters
    ) internal returns (bool) {
        // Determine the basic order route type from the basic order type.
        BasicOrderRouteType route;
        {
            BasicOrderType basicType = parameters.basicOrderType;
            route = _OrderToRouteType[basicType];
        }

        // Determine the order type from the basic order type.
        OrderType orderType;
        {
            BasicOrderType basicType = parameters.basicOrderType;
            orderType = _BasicOrderToOrderType[basicType];
        }

        // // Declare additional recipient item type to derive from the route type.
        // ItemType additionalRecipientsItemType;
        // if (
        //     route == BasicOrderRouteType.ETH_TO_ERC721 ||
        //     route == BasicOrderRouteType.ETH_TO_ERC1155
        // ) {
        //     additionalRecipientsItemType = ItemType.NATIVE;
        // } else {
        //     additionalRecipientsItemType = ItemType.ERC20;
        // }

        // // Revert if msg.value was not supplied as part of a payable route.
        // if (msg.value == 0 && additionalRecipientsItemType == ItemType.NATIVE) {
        //     revert InvalidMsgValue(msg.value);
        // }

        // // Revert if msg.value was supplied as part of a non-payable route.
        // if (msg.value != 0 && additionalRecipientsItemType == ItemType.ERC20) {
        //     revert InvalidMsgValue(msg.value);
        // }

        // // Determine the token that additional recipients should have set.
        // address additionalRecipientsToken;
        // if (
        //     route == BasicOrderRouteType.ERC721_TO_ERC20 ||
        //     route == BasicOrderRouteType.ERC1155_TO_ERC20
        // ) {
        //     additionalRecipientsToken = parameters.offerToken;
        // } else {
        //     additionalRecipientsToken = parameters.considerationToken;
        // }

        // // Determine the item type for received items.
        // ItemType receivedItemType;
        // if (
        //     route == BasicOrderRouteType.ETH_TO_ERC721 ||
        //     route == BasicOrderRouteType.ETH_TO_ERC1155
        // ) {
        //     receivedItemType = ItemType.NATIVE;
        // } else if (
        //     route == BasicOrderRouteType.ERC20_TO_ERC721 ||
        //     route == BasicOrderRouteType.ERC20_TO_ERC1155
        // ) {
        //     receivedItemType = ItemType.ERC20;
        // } else if (route == BasicOrderRouteType.ERC721_TO_ERC20) {
        //     receivedItemType = ItemType.ERC721;
        // } else {
        //     receivedItemType = ItemType.ERC1155;
        // }

        // // Determine the item type for the offered item.
        // ItemType offeredItemType;
        // if (
        //     route == BasicOrderRouteType.ERC721_TO_ERC20 ||
        //     route == BasicOrderRouteType.ERC1155_TO_ERC20
        // ) {
        //     offeredItemType = ItemType.ERC20;
        // } else if (
        //     route == BasicOrderRouteType.ETH_TO_ERC721 ||
        //     route == BasicOrderRouteType.ERC20_TO_ERC721
        // ) {
        //     offeredItemType = ItemType.ERC721;
        // } else {
        //     offeredItemType = ItemType.ERC1155;
        // }

        // // Derive & validate order using parameters and update order status.
        // bytes32 orderHash = _prepareBasicFulfillment(
        //     parameters,
        //     orderType,
        //     receivedItemType,
        //     additionalRecipientsItemType,
        //     additionalRecipientsToken,
        //     offeredItemType
        // );

        // // Determine conduitKey argument used by transfer functions.
        // bytes32 conduitKey;
        // if (
        //     route == BasicOrderRouteType.ERC721_TO_ERC20 ||
        //     route == BasicOrderRouteType.ERC1155_TO_ERC20
        // ) {
        //     conduitKey = parameters.fulfillerConduitKey;
        // } else {
        //     conduitKey = parameters.offererConduitKey;
        // }

        // // Check for dirtied unused parameters.
        // if (
        //     ((route == BasicOrderRouteType.ETH_TO_ERC721 ||
        //         route == BasicOrderRouteType.ETH_TO_ERC1155) &&
        //         (uint160(parameters.considerationToken) |
        //             parameters.considerationIdentifier) !=
        //         0) ||
        //     ((route == BasicOrderRouteType.ERC20_TO_ERC721 ||
        //         route == BasicOrderRouteType.ERC20_TO_ERC1155) &&
        //         parameters.considerationIdentifier != 0) ||
        //     ((route == BasicOrderRouteType.ERC721_TO_ERC20 ||
        //         route == BasicOrderRouteType.ERC1155_TO_ERC20) &&
        //         parameters.offerIdentifier != 0)
        // ) {
        //     revert UnusedItemParameters();
        // }

        // // Declare transfer accumulator that will collect transfers that can be
        // // bundled into a single call to their associated conduit.
        // AccumulatorStruct memory accumulatorStruct;

        // // Transfer tokens based on the route.
        // if (route == BasicOrderRouteType.ETH_TO_ERC721) {
        //     // Transfer ERC721 to caller using offerer's conduit if applicable.
        //     _transferERC721(
        //         parameters.offerToken,
        //         parameters.offerer,
        //         msg.sender,
        //         parameters.offerIdentifier,
        //         parameters.offerAmount,
        //         conduitKey,
        //         accumulatorStruct
        //     );

        //     // Transfer native to recipients, return excess to caller & wrap up.
        //     _transferEthAndFinalize(parameters.considerationAmount, parameters);
        // } else if (route == BasicOrderRouteType.ETH_TO_ERC1155) {
        //     // Transfer ERC1155 to caller using offerer's conduit if applicable.
        //     _transferERC1155(
        //         parameters.offerToken,
        //         parameters.offerer,
        //         msg.sender,
        //         parameters.offerIdentifier,
        //         parameters.offerAmount,
        //         conduitKey,
        //         accumulatorStruct
        //     );

        //     // Transfer native to recipients, return excess to caller & wrap up.
        //     _transferEthAndFinalize(parameters.considerationAmount, parameters);
        // } else if (route == BasicOrderRouteType.ERC20_TO_ERC721) {
        //     // Transfer ERC721 to caller using offerer's conduit if applicable.
        //     _transferERC721(
        //         parameters.offerToken,
        //         parameters.offerer,
        //         msg.sender,
        //         parameters.offerIdentifier,
        //         parameters.offerAmount,
        //         conduitKey,
        //         accumulatorStruct
        //     );

        //     // Transfer ERC20 tokens to all recipients and wrap up.
        //     _transferERC20AndFinalize(
        //         msg.sender,
        //         parameters.offerer,
        //         parameters.considerationToken,
        //         parameters.considerationAmount,
        //         parameters,
        //         false, // Send full amount indicated by all consideration items.
        //         accumulatorStruct
        //     );
        // } else if (route == BasicOrderRouteType.ERC20_TO_ERC1155) {
        //     // Transfer ERC1155 to caller using offerer's conduit if applicable.
        //     _transferERC1155(
        //         parameters.offerToken,
        //         parameters.offerer,
        //         msg.sender,
        //         parameters.offerIdentifier,
        //         parameters.offerAmount,
        //         conduitKey,
        //         accumulatorStruct
        //     );

        //     // Transfer ERC20 tokens to all recipients and wrap up.
        //     _transferERC20AndFinalize(
        //         msg.sender,
        //         parameters.offerer,
        //         parameters.considerationToken,
        //         parameters.considerationAmount,
        //         parameters,
        //         false, // Send full amount indicated by all consideration items.
        //         accumulatorStruct
        //     );
        // } else if (route == BasicOrderRouteType.ERC721_TO_ERC20) {
        //     // Transfer ERC721 to offerer using caller's conduit if applicable.
        //     _transferERC721(
        //         parameters.considerationToken,
        //         msg.sender,
        //         parameters.offerer,
        //         parameters.considerationIdentifier,
        //         parameters.considerationAmount,
        //         conduitKey,
        //         accumulatorStruct
        //     );

        //     // Transfer ERC20 tokens to all recipients and wrap up.
        //     _transferERC20AndFinalize(
        //         parameters.offerer,
        //         msg.sender,
        //         parameters.offerToken,
        //         parameters.offerAmount,
        //         parameters,
        //         true, // Reduce amount sent to fulfiller by additional amounts.
        //         accumulatorStruct
        //     );
        // } else {
        //     // route == BasicOrderRouteType.ERC1155_TO_ERC20

        //     // Transfer ERC1155 to offerer using caller's conduit if applicable.
        //     _transferERC1155(
        //         parameters.considerationToken,
        //         msg.sender,
        //         parameters.offerer,
        //         parameters.considerationIdentifier,
        //         parameters.considerationAmount,
        //         conduitKey,
        //         accumulatorStruct
        //     );

        //     // Transfer ERC20 tokens to all recipients and wrap up.
        //     _transferERC20AndFinalize(
        //         parameters.offerer,
        //         msg.sender,
        //         parameters.offerToken,
        //         parameters.offerAmount,
        //         parameters,
        //         true, // Reduce amount sent to fulfiller by additional amounts.
        //         accumulatorStruct
        //     );
        // }

        // // Trigger any remaining accumulated transfers via call to the conduit.
        // _triggerIfArmed(accumulatorStruct);

        // // Determine whether order is restricted and, if so, that it is valid.
        // _assertRestrictedBasicOrderValidity(
        //     orderHash,
        //     orderType,
        //     parameters,
        //     offeredItemType,
        //     receivedItemType
        // );

        // return true;
    }

    function _domainSeparator() internal view returns (bytes32) {
        return 0xb50c8913581289bd2e066aeef89fceb9615d490d673131fd1a7047436706834e;
    }

    function _deriveEIP712Digest(
        bytes32 domainSeparator,
        bytes32 orderHash
    ) internal pure returns (bytes32 value) {
        value = keccak256(
            abi.encodePacked(uint16(0x1901), domainSeparator, orderHash)
        );
    }

    function _isValidBulkOrderSize(
        bytes memory signature
    ) internal pure returns (bool validLength) {
        validLength =
            signature.length < 837 &&
            signature.length > 98 &&
            ((signature.length - 67) % 32) < 2;
    }


    function _computeBulkOrderProof(
        bytes memory proofAndSignature,
        bytes32 leaf
    ) internal view returns (bytes32 bulkOrderHash, bytes memory signature) {
        bytes32 root = leaf;

        // proofAndSignature with odd length is a compact signature (64 bytes).
        uint256 length = proofAndSignature.length % 2 == 0 ? 65 : 64;

        // Create a new array of bytes equal to the length of the signature.
        signature = new bytes(length);

        // Iterate over each byte in the signature.
        for (uint256 i = 0; i < length; ++i) {
            // Assign the byte from the proofAndSignature to the signature.
            signature[i] = proofAndSignature[i];
        }

        // Compute the key by extracting the next three bytes from the
        // proofAndSignature.
        uint256 key = (((uint256(uint8(proofAndSignature[length])) << 16) |
            ((uint256(uint8(proofAndSignature[length + 1]))) << 8)) |
            (uint256(uint8(proofAndSignature[length + 2]))));

        uint256 height = (proofAndSignature.length - length) / 32;

        // Create an array of bytes32 to hold the proof elements.
        bytes32[] memory proofElements = new bytes32[](height);

        // Iterate over each proof element.
        for (uint256 elementIndex = 0; elementIndex < height; ++elementIndex) {
            // Compute the starting index for the current proof element.
            uint256 start = (length + 3) + (elementIndex * 32);

            // Create a new array of bytes to hold the current proof element.
            bytes memory buffer = new bytes(32);

            // Iterate over each byte in the proof element.
            for (uint256 i = 0; i < 32; ++i) {
                // Assign the byte from the proofAndSignature to the buffer.
                buffer[i] = proofAndSignature[start + i];
            }

            // Decode the current proof element from the buffer and assign it to
            // the proofElements array.
            proofElements[elementIndex] = abi.decode(buffer, (bytes32));
        }

        // Iterate over each proof element.
        for (uint256 i = 0; i < proofElements.length; ++i) {
            // Retrieve the proof element.
            bytes32 proofElement = proofElements[i];

            // Check if the current bit of the key is set.
            if ((key >> i) % 2 == 0) {
                // If the current bit is not set, then concatenate the root and
                // the proof element, and compute the keccak256 hash of the
                // concatenation to assign it to the root.
                root = keccak256(abi.encodePacked(root, proofElement));
            } else {
                // If the current bit is set, then concatenate the proof element
                // and the root, and compute the keccak256 hash of the
                // concatenation to assign it to the root.
                root = keccak256(abi.encodePacked(proofElement, root));
            }
        }

        // Compute the bulk order hash and return it.
        bulkOrderHash = keccak256(
            abi.encodePacked(_bulkOrderTypehashes[height], root)
        );

        // Return the signature.
        return (bulkOrderHash, signature);
    }

    mapping(uint256 => bytes32) internal _bulkOrderTypehashes;

    function _verifySignature(
        address offerer,
        bytes32 orderHash,
        bytes memory signature
    ) internal view returns (bytes32 actualDigest) {

        // bytes32 r;
        // bytes32 s;
        // uint8 v;

        // (r, s) = abi.decode(signature, (bytes32, bytes32));
        // v = uint8(signature[64]);

        // Derive EIP-712 digest using the domain separator and the order hash.
        bytes32 digest = _deriveEIP712Digest(_domainSeparator(), orderHash);

        bytes32 r = 0x5fb612dac8b3b7fc4c4bc4609998000a783483828baaee7e24253582dcfadb01;
        bytes32 s = 0x335f6e690f6d8c327769fe53b0fc04fca9bca95ad117985c1c732ff4a6c65a37;
        uint8 v = 0x1c;

        address recoveredSigner = ecrecover(digest, v, r, s);
        console2.log("recoveredSigner", recoveredSigner);
        console2.logBytes32(digest);
        console2.logBytes32(orderHash); // 0x3037da4e9949ec07389964478ca398fa059940f23f4e5dff31c2bfedcde9994e
        console2.logBytes32(_domainSeparator()); // 0xb50c8913581289bd2e066aeef89fceb9615d490d673131fd1a7047436706834e

        return digest;
    }
}
