// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "./TestHelpers.t.sol";
import "../src/ERC777TokenBuyerBondingCurve.sol";
import "../src/erc777/ERC777Token.sol";

contract ERC777TokenBuyerBondingCurveTest is TestHelpers {
    /*//////////////////////////////////////////////////////////////
                                 STATE
    //////////////////////////////////////////////////////////////*/

    ERC777TokenBuyerBondingCurve public bondingToken;
    ERC777Token public erc777;
    address public user1;
    address public user2;

    /*//////////////////////////////////////////////////////////////
                                 SETUP
    //////////////////////////////////////////////////////////////*/

    function setUp() public {
        vm.rollFork(17676290);

        bondingToken = new ERC777TokenBuyerBondingCurve();
        user1 = createAndDealUser();
        user2 = createAndDealUser();
        address[] memory defaultOperators = new address[](1);
        defaultOperators[0] = address(this);
        erc777 = new ERC777Token(
            "ERC777TokenBuyerBondingCurve",
            "BT",
            defaultOperators
        );
        erc777.mint(user1, 1000 ether);
        erc777.mint(user2, 1000 ether);
    }

    /*//////////////////////////////////////////////////////////////
                              ERC20 TESTS
    //////////////////////////////////////////////////////////////*/

    function testName() public {
        assertEq(bondingToken.name(), "ERC777TokenBuyerBondingCurve");
    }

    function testSymbol() public {
        assertEq(bondingToken.symbol(), "BT");
    }

    /*//////////////////////////////////////////////////////////////
                             PURCHASE TESTS
    //////////////////////////////////////////////////////////////*/

    function test_First_Purchase_0() public {
        uint256 maxEntryPrice = 0;
        vm.prank(user1);
        vm.expectRevert(
            ERC777TokenBuyerBondingCurve.MustPayGreaterThanZero.selector
        );
        erc777.send(address(bondingToken), 0, abi.encodePacked(maxEntryPrice));
    }

    function test_First_Purchase_1() public {
        uint256 maxEntryPrice = 0;
        vm.prank(user1);
        erc777.send(address(bondingToken), 1, abi.encodePacked(maxEntryPrice));
        assertEq(bondingToken.balanceOf(user1), 1);
    }

    function test_First_Purchase_3() public {
        uint256 maxEntryPrice = 0;
        vm.prank(user1);
        erc777.send(address(bondingToken), 3, abi.encodePacked(maxEntryPrice));
        assertEq(bondingToken.balanceOf(user1), 2);
    }

    function test_First_Purchase_8() public {
        uint256 maxEntryPrice = 0;
        vm.prank(user1);
        erc777.send(address(bondingToken), 8, abi.encodePacked(maxEntryPrice));
        assertEq(bondingToken.balanceOf(user1), 4);
    }

    function test_First_Purchase_1000() public {
        uint256 maxEntryPrice = 0;
        vm.prank(user1);
        erc777.send(
            address(bondingToken),
            1000,
            abi.encodePacked(maxEntryPrice)
        );
        assertEq(bondingToken.balanceOf(user1), 44);
    }

    function test_First_Purchase_Fuzz(uint64 purchaseAmount) public {
        vm.assume(purchaseAmount > 0);

        uint256 maxEntryPrice = 0;
        vm.prank(user1);
        erc777.send(
            address(bondingToken),
            purchaseAmount,
            abi.encodePacked(maxEntryPrice)
        );

        assertEq(
            bondingToken.balanceOf(user1),
            calculateSupplyChange(0, purchaseAmount)
        );
    }

    function test_Second_Purchase() public {
        uint256 maxEntryPrice = 0;
        vm.prank(user1);
        erc777.send(
            address(bondingToken),
            1000,
            abi.encodePacked(maxEntryPrice)
        );

        // firstPurchaseReserves = 1000
        // firstPurchaseSupply = sqrt(1000 * 2) = 44
        // newReservers = 2000
        // newSupply = sqrt(2000 * 2) = 63
        // change in supply = 63 - 44 = 19

        maxEntryPrice = 44;
        vm.prank(user2);
        erc777.send(
            address(bondingToken),
            1000,
            abi.encodePacked(maxEntryPrice)
        );
        assertEq(bondingToken.balanceOf(user2), 19);
    }

    /*//////////////////////////////////////////////////////////////
                                HELPERS
    //////////////////////////////////////////////////////////////*/

    function calculateSupplyChange(
        uint256 initialReserves,
        uint256 addedReserves
    ) internal pure returns (uint256) {
        uint256 newReserves = initialReserves + addedReserves;

        uint256 initialSupply = sqrt(initialReserves * 2);
        uint256 newSupply = sqrt(newReserves * 2);

        return newSupply - initialSupply;
    }

    function calculatePayout(
        uint256 initialTotalSupply,
        uint256 oldReserves,
        uint256 amountBurnt
    ) internal pure returns (uint256) {
        uint256 newTotalSupply = initialTotalSupply - amountBurnt;
        uint256 newReserves = (newTotalSupply ** 2) / 2;
        return oldReserves - newReserves;
    }
}
