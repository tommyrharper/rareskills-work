// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Week22Exercise2} from "../src/Week22Exercise2.sol";

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Week22Exercise2Test is Test {
    using Strings for uint256;
    using MessageHashUtils for bytes32;
    using ECDSA for bytes32;
    Week22Exercise2 public exercise;

    address owner;
    uint256 privateKey =
        0x1010101010101010101010101010101010101010101010101010101010101010;

    function setUp() public {
        owner = vm.addr(privateKey);
        exercise = new Week22Exercise2();
    }

    // function test_attack() public {
    //     string memory message = "attack";

    //     bytes32 msgHash = keccak256(abi.encode(message))
    //         .toEthSignedMessageHash();

    //     (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, msgHash);

    //     bytes memory signature = abi.encodePacked(r, s, v);
    //     assertEq(signature.length, 65);

    //     exercise.challenge(message, signature);
    // }

    // 0xe5d0b13209c030a26b72ddb84866ae7b32f806d64f28136cb5516ab6ca15d3c438d9e7c79efa063198fda1a5b48e878a954d79372ed71922003f847029bf2e751b
    // e5d0b13209c030a26b72ddb84866ae7b32f806d64f28136cb5516ab6ca15d3c4
    // 38d9e7c79efa063198fda1a5b48e878a954d79372ed71922003f847029bf2e75
    // 1b

    function getSignature() internal returns (bytes memory) {
        bytes32 r = 0xe5d0b13209c030a26b72ddb84866ae7b32f806d64f28136cb5516ab6ca15d3c4;
        bytes32 s = 0x38d9e7c79efa063198fda1a5b48e878a954d79372ed71922003f847029bf2e75;
        uint8 v = 27;
        return abi.encodePacked(r, s, v);
    }

    function test_attack() public {
        string memory message = "attack at dawn";
        bytes memory signature = getSignature();

        // bytes32 msgHash = keccak256(abi.encode(message))
        //     .toEthSignedMessageHash();

        // (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, msgHash);

        // bytes memory signature = abi.encodePacked(r, s, v);
        // assertEq(signature.length, 65);

        exercise.challenge(message, signature);
    }


    // function test_attack() public {
    //     bool success = false;
    //     uint256 num;
    //     while (!success) {
    //         string memory message = "attack at dawn";
    //         bytes32 msgHash = keccak256(abi.encode(num))
    //             .toEthSignedMessageHash();

    //         (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, msgHash);

    //         bytes memory signature = abi.encodePacked(r, s, v);

    //         try exercise.challenge(message, signature) {
    //             console.log("num:", num);
    //             success = true;
    //         } catch {
    //             num++;
    //         }
    //     }
    // }
}
