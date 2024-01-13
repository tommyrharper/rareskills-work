// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {PermitToken} from "../src/PermitToken.sol";

contract SigUtils is Test {
    /// @notice The EIP-712 typehash for the contract's domain
    bytes32 public constant DOMAIN_TYPEHASH =
        keccak256(
            "EIP712Domain(string name,uint256 chainId,address verifyingContract)"
        );
    bytes32 public constant PERMIT_TYPEHASH =
        keccak256(
            "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
        );

    struct Permit {
        address owner;
        address spender;
        uint256 value;
        uint256 nonce;
        uint256 deadline;
    }

    bytes32 internal DOMAIN_SEPARATOR;
    PermitToken permitToken;

    constructor(address _verifyingContract) {
        permitToken = PermitToken(_verifyingContract);
        DOMAIN_SEPARATOR = permitToken.DOMAIN_SEPARATOR();
    }

    // computes the hash of a ballot
    function getStructHash(
        Permit memory _permit
    ) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    PERMIT_TYPEHASH,
                    _permit.owner,
                    _permit.spender,
                    _permit.value,
                    _permit.nonce,
                    _permit.deadline
                )
            );
    }

    // computes the hash of the fully encoded EIP-712 message for the domain, which can be used to recover the signer
    function getTypedDataHash(
        Permit memory _permit
    ) public view returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    DOMAIN_SEPARATOR,
                    getStructHash(_permit)
                )
            );
    }

    // computes incorrect hash of the fully encoded EIP-712 message for the domain, which can be used to recover the signer
    function getDodgyTypedDataHash(
        Permit memory _permit
    ) public view returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    "\x19\x02",
                    DOMAIN_SEPARATOR,
                    getStructHash(_permit)
                )
            );
    }

    function getSignedPermit(
        uint256 privateKey,
        address _owner,
        address _spender,
        uint256 _value
    ) internal view returns (Permit memory, uint8, bytes32, bytes32) {
        uint256 nextNonce = permitToken.nonces(_owner);

        Permit memory permit = Permit({
            owner: _owner,
            spender: _spender,
            value: _value,
            nonce: nextNonce,
            deadline: block.timestamp + 1000
        });

        bytes32 digest = getTypedDataHash(permit);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);

        return (permit, v, r, s);
    }
}
