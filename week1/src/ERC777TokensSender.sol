// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

interface ERC777TokensSender {
    function tokensToSend(
        address operator,
        address from,
        address to,
        uint amount,
        bytes memory userData,
        bytes memory operatorData
    ) external;
}
