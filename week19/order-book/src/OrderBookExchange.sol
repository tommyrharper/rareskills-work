// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

struct Permit {
    address owner;
    address spender;
    uint256 value;
    uint256 nonce;
    uint256 deadline;
}

contract OrderBookExchange {
    function matchOrders(
        Permit memory permitA,
        uint8 vA,
        bytes32 rA,
        bytes32 sA,
        Permit memory permitB,
        uint8 vB,
        bytes32 rB,
        bytes32 sB
    ) external {}
}
