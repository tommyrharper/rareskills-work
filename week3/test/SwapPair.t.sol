// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/SwapPair.sol";
import "../src/Factory.sol";
import "./MintableERC20.t.sol";
import "lib/openzeppelin-contracts/contracts/utils/math/Math.sol";
import "./ERC3156FlashBorrowerMock.t.sol";

contract SwapPairTest is Test {
    /*//////////////////////////////////////////////////////////////
                                 STATE
    //////////////////////////////////////////////////////////////*/

    Factory public factory;
    SwapPair public swapPair;
    MintableERC20 public tokenA;
    MintableERC20 public tokenB;
    ERC3156FlashBorrowerMock public borrower;

    /*//////////////////////////////////////////////////////////////
                                 SETUP
    //////////////////////////////////////////////////////////////*/

    function setUp() public {
        tokenA = new MintableERC20("TokenA", "TA");
        tokenB = new MintableERC20("TokenB", "TB");
        factory = new Factory(address(this));
        address pair = factory.createPair(address(tokenA), address(tokenB));
        swapPair = SwapPair(pair);
    }

    /*//////////////////////////////////////////////////////////////
                               FIRST MINT
    //////////////////////////////////////////////////////////////*/

    function test_Equal_First_Mint() public {
        sendAndMint(10_000);
        assertEq(swapPair.balanceOf(address(this)), 9_000);
    }

    function test_Equal_First_Mint_Fuzz(uint64 amount) public {
        uint256 minLiquidity = swapPair.MINIMUM_LIQUIDITY();
        sendTokensToSwapPair(amount);
        if (amount <= minLiquidity) {
            vm.expectRevert();
            swapPair.mint(address(this));
        } else {
            swapPair.mint(address(this));
            assertEq(swapPair.balanceOf(address(this)), amount - minLiquidity);
        }
    }

    function test_Unequal_First_Mint() public {
        sendAndMint(25_000, 1_000);
        assertEq(swapPair.balanceOf(address(this)), 4_000);
    }

    function test_Unequal_First_Mint_Fuzz(
        uint64 _amountA,
        uint64 _amountB
    ) public {
        uint256 amountA = _amountA;
        uint256 amountB = _amountB;
        uint256 minLiquidity = swapPair.MINIMUM_LIQUIDITY();
        uint256 sqrt = Math.sqrt(amountA * amountB);
        sendTokensToSwapPair(amountA, amountB);
        if (sqrt <= minLiquidity) {
            vm.expectRevert();
            swapPair.mint(address(this));
        } else {
            swapPair.mint(address(this));
            assertEq(swapPair.balanceOf(address(this)), sqrt - minLiquidity);
        }
    }

    /*//////////////////////////////////////////////////////////////
                              SECOND MINT
    //////////////////////////////////////////////////////////////*/

    function test_Equal_Second_Mint() public {
        sendAndMint(10_000);
        assertEq(swapPair.balanceOf(address(this)), 9_000);
        sendAndMint(10_000);
        assertEq(swapPair.balanceOf(address(this)), 19_000);
    }

    function test_Equal_Second_Mint_Fuzz(uint64 _amount) public {
        uint256 amount = _amount;
        sendAndMint(10_000);
        assertEq(swapPair.balanceOf(address(this)), 9_000);
        sendTokensToSwapPair(amount);
        if (amount <= 0) {
            vm.expectRevert("UniswapV2: INSUFFICIENT_LIQUIDITY_MINTED");
            swapPair.mint(address(this));
        } else {
            swapPair.mint(address(this));
            assertEq(swapPair.balanceOf(address(this)), 9_000 + amount);
        }
    }

    /*//////////////////////////////////////////////////////////////
                                  BURN
    //////////////////////////////////////////////////////////////*/

    function test_Burn() public {
        sendAndMint(10_000);
        assertEq(swapPair.balanceOf(address(this)), 9_000);
        swapPair.transfer(address(swapPair), 1_000);
        swapPair.burn(address(this));
        assertEq(swapPair.balanceOf(address(this)), 8_000);
        assertEq(tokenA.balanceOf(address(this)), 1_000);
        assertEq(tokenB.balanceOf(address(this)), 1_000);
    }

    function test_Burn_Fuzz(
        uint64 _tokenADeposit,
        uint64 _tokenBDeposit,
        uint8 _proportionToBurn
    ) public {
        uint256 tokenADeposit = _tokenADeposit;
        uint256 tokenBDeposit = _tokenBDeposit;
        uint256 proportionToBurn = _proportionToBurn;
        vm.assume(tokenADeposit > 1000 && tokenBDeposit > 1000);
        vm.assume(proportionToBurn > 0 && proportionToBurn <= 100);

        sendAndMint(tokenADeposit, tokenBDeposit);
        uint256 lpTokens = swapPair.balanceOf(address(this));
        uint256 totalSupply = swapPair.totalSupply();
        uint256 toBurn = (lpTokens * proportionToBurn) / 100;
        vm.assume(toBurn > 0);

        swapPair.transfer(address(swapPair), toBurn);
        swapPair.burn(address(this));

        assertEq(swapPair.balanceOf(address(this)), lpTokens - toBurn);

        uint256 proportionARedeemed = (toBurn * tokenADeposit) / totalSupply;
        uint256 proportionBRedeemed = (toBurn * tokenBDeposit) / totalSupply;
        assertEq(tokenA.balanceOf(address(this)), proportionARedeemed);
        assertEq(tokenB.balanceOf(address(this)), proportionBRedeemed);
    }

    /*//////////////////////////////////////////////////////////////
                                  SWAP
    //////////////////////////////////////////////////////////////*/

    function test_Swap_A_For_B() public {
        sendAndMint(10_000);

        tokenA.mint(address(swapPair), 1_000);
        swapPair.swap(900, 0, address(this));

        assertEq(tokenA.balanceOf(address(this)), 0);
        assertEq(tokenB.balanceOf(address(this)), 900);
    }

    function test_Swap_B_For_A() public {
        sendAndMint(10_000);

        tokenB.mint(address(swapPair), 1_000);
        swapPair.swap(0, 900, address(this));

        assertEq(tokenA.balanceOf(address(this)), 900);
        assertEq(tokenB.balanceOf(address(this)), 0);
    }

    /*//////////////////////////////////////////////////////////////
                               FLASH LOAN
    //////////////////////////////////////////////////////////////*/

    function test_Flash_Loan_Token_A() public {
        borrower = new ERC3156FlashBorrowerMock(true, true);
        tokenA.mint(address(swapPair), 1 ether);
        tokenA.mint(address(borrower), 0.003 ether);

        swapPair.flashLoan(borrower, address(tokenA), 1 ether, new bytes(0));
    }

    function test_Flash_Loan_Token_B() public {
        borrower = new ERC3156FlashBorrowerMock(true, true);
        tokenB.mint(address(swapPair), 1 ether);
        tokenB.mint(address(borrower), 0.003 ether);

        swapPair.flashLoan(borrower, address(tokenB), 1 ether, new bytes(0));
    }

    function test_Does_Not_Loan_If_No_Return_Val() public {
        borrower = new ERC3156FlashBorrowerMock(false, true);
        tokenA.mint(address(swapPair), 1 ether);
        tokenA.mint(address(borrower), 0.003 ether);

        vm.expectRevert("FlashLender: Callback failed");
        swapPair.flashLoan(borrower, address(tokenA), 1 ether, new bytes(0));
    }

    function test_Does_Not_Loan_If_Not_Paid_Back() public {
        borrower = new ERC3156FlashBorrowerMock(true, false);
        tokenA.mint(address(swapPair), 1 ether);
        tokenA.mint(address(borrower), 0.003 ether);

        vm.expectRevert();
        swapPair.flashLoan(borrower, address(tokenA), 1 ether, new bytes(0));
    }

    function test_Loan_Fails_If_Not_Enough_To_Pay_Back() public {
        borrower = new ERC3156FlashBorrowerMock(true, true);
        tokenA.mint(address(swapPair), 1 ether);
        tokenA.mint(address(borrower), 0.002 ether);

        vm.expectRevert();
        swapPair.flashLoan(borrower, address(tokenA), 1 ether, new bytes(0));
    }

    function test_Loan_Fails_With_Invalid_Token() public {
        borrower = new ERC3156FlashBorrowerMock(true, true);
        tokenA.mint(address(swapPair), 1 ether);
        tokenA.mint(address(borrower), 0.003 ether);

        vm.expectRevert("FlashLender: Unsupported currency");
        swapPair.flashLoan(borrower, address(0xA), 1 ether, new bytes(0));
    }

    function test_Loan_Amount_Must_Be_Greater_Than_Zero() public {
        borrower = new ERC3156FlashBorrowerMock(true, true);
        tokenA.mint(address(swapPair), 1 ether);
        tokenA.mint(address(borrower), 0.003 ether);

        vm.expectRevert("FlashLoan: Amount must be greater than 0");
        swapPair.flashLoan(borrower, address(tokenA), 0, new bytes(0));
    }

    function test_MaxFlashLoan() public {
        // tokenA
        tokenA.mint(address(swapPair), 1 ether);
        uint256 max = swapPair.maxFlashLoan(address(tokenA));
        assertEq(max, 1 ether);

        // tokenB
        tokenB.mint(address(swapPair), 2 ether);
        max = swapPair.maxFlashLoan(address(tokenB));
        assertEq(max, 2 ether);

        // invalid token
        max = swapPair.maxFlashLoan(address(0xA));
        assertEq(max, 0);
    }

    function test_FlashFee() public {
        // tokenA
        tokenA.mint(address(swapPair), 1 ether);
        uint256 fee = swapPair.flashFee(address(tokenA), 1 ether);
        assertEq(fee, 0.003 ether);

        // tokenB
        tokenB.mint(address(swapPair), 2 ether);
        fee = swapPair.flashFee(address(tokenB), 2 ether);
        assertEq(fee, 0.006 ether);

        // invalid token
        vm.expectRevert("FlashLender: Unsupported currency");
        swapPair.flashFee(address(0xA), 0);
    }

    /*//////////////////////////////////////////////////////////////
                                HELPERS
    //////////////////////////////////////////////////////////////*/

    function sendAndMint(uint256 amount) public {
        sendTokensToSwapPair(amount);
        swapPair.mint(address(this));
    }

    function sendAndMint(uint256 tokenAAmount, uint256 tokenBAmount) public {
        sendTokensToSwapPair(tokenAAmount, tokenBAmount);
        swapPair.mint(address(this));
    }

    function sendTokensToSwapPair(uint256 amount) public {
        tokenA.mint(address(swapPair), amount);
        tokenB.mint(address(swapPair), amount);
    }

    function sendTokensToSwapPair(
        uint256 tokenAAmount,
        uint256 tokenBAmount
    ) public {
        tokenA.mint(address(swapPair), tokenAAmount);
        tokenB.mint(address(swapPair), tokenBAmount);
    }
}
