// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {PermitToken, Permit} from "./PermitToken.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {Nonces} from "@openzeppelin/contracts/utils/Nonces.sol";

struct Order {
    address owner;
    address sellToken;
    address buyToken;
    uint256 sellAmount;
    uint256 buyAmount;
    uint256 expires;
    uint256 nonce;
}

contract OrderBookExchange is EIP712, Nonces {
    bytes32 public constant ORDER_TYPEHASH =
        keccak256(
            "Order(addres owner,address sellToken,address buyToken,uint256 sellAmount,uint256 buyAmount,uint256 expires,uint256 nonce)"
        );

    PermitToken public tokenA;
    PermitToken public tokenB;

    constructor(
        PermitToken _tokenA,
        PermitToken _tokenB
    ) EIP712("OrderBookExchange", "1") {
        tokenA = _tokenA;
        tokenB = _tokenB;
    }

    function matchOrders(
        Permit memory permitA,
        uint8 vA,
        bytes32 rA,
        bytes32 sA,
        Permit memory permitB,
        uint8 vB,
        bytes32 rB,
        bytes32 sB
    ) external {
        // require(permitA)
    }

    function checkOrderIsValid(
        Order memory order,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        if (block.timestamp > order.expires) {
            revert ExpiredSignature(order.expires);
        }

        bytes32 structHash = keccak256(
            abi.encode(
                ORDER_TYPEHASH,
                order.owner,
                order.sellToken,
                order.buyToken,
                order.sellAmount,
                order.buyAmount,
                order.expires,
                _useNonce(order.owner)
            )
        );

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ECDSA.recover(hash, v, r, s);
        if (signer != order.owner) {
            revert InvalidSigner(signer, order.owner);
        }
    }

    function DOMAIN_SEPARATOR() external view virtual returns (bytes32) {
        return _domainSeparatorV4();
    }

    error ExpiredSignature(uint256 deadline);
    error InvalidSigner(address signer, address owner);
}
