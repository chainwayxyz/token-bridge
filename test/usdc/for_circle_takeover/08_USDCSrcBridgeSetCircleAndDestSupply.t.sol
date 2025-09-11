// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./base/USDCSrcBridgePrepareTakeoverBase.t.sol";
import {USDCSrcBridgeSetCircleAndDestSupply} from "../../../script/usdc/for_circle_takeover/08_USDCSrcBridgeSetCircleAndDestSupply.s.sol";
import {MasterMinter} from "../../../src/interfaces/IMasterMinter.sol";

contract USDCSrcBridgeSetCircleTest is USDCSrcBridgePrepareTakeoverTestBase, USDCSrcBridgeSetCircleAndDestSupply {
    uint256 public destUSDCSupply;
    address public circle;

    function setUp() public override (USDCSrcBridgeSetCircleAndDestSupply, USDCSrcBridgePrepareTakeoverTestBase) {
        USDCSrcBridgePrepareTakeoverTestBase.setUp();

        vm.selectFork(destForkId);
        destUSDCSupply = FiatTokenV2_2(DEST_USDC).totalSupply();

        vm.selectFork(srcForkId);
        vm.startPrank(srcUSDCBridge.owner());
        circle = makeAddr("CIRCLE_ADDRESS");
        USDCSrcBridgeSetCircleAndDestSupply._run(false, address(srcUSDCBridge), circle, destUSDCSupply);
        vm.stopPrank();

        // Circle should set `srcUSDCBridge` as a zero-allowance minter on Source USDC so that it can burn its balance
        MasterMinter srcMM = MasterMinter(FiatTokenV2_2(SRC_USDC).masterMinter());
        address srcMMOwner = srcMM.owner();
        vm.startPrank(srcMMOwner);
        srcMM.configureController(srcMMOwner, address(srcUSDCBridge));
        srcMM.configureMinter(0);
        vm.stopPrank();
    }

    function run() public override (USDCSrcBridgeSetCircleAndDestSupply, USDCSrcBridgePrepareTakeover) {}

    function testSetCircle() public view {
        assertEq(SourceOFTAdapter(address(srcUSDCBridge)).circle(), circle, "Circle address should be set correctly");
    }

    function testCircleCanBurnLockedUSDC() public {
        vm.startPrank(circle);
        // Sending extra 1 USDC to the bridge to verify that Circle can only burn up to `destUSDCSupply`
        uint256 excess = 1e6;
        uint256 amountToBurn = destUSDCSupply + excess;
        deal(SRC_USDC, address(srcUSDCBridge), amountToBurn);
        assertEq(FiatTokenV2_2(SRC_USDC).balanceOf(address(srcUSDCBridge)), amountToBurn, "Bridge should have USDC to burn");
        SourceOFTAdapter(address(srcUSDCBridge)).burnLockedUSDC();
        assertEq(FiatTokenV2_2(SRC_USDC).balanceOf(address(srcUSDCBridge)), excess, "Circle should be able to burn locked USDC");
    }

    function testBalanceIsBurnedIfDestSupplyIsMoreThanBalance() public {
        vm.startPrank(circle);
        // Sending less than `destUSDCSupply` to the bridge to verify that Circle burns only the balance
        uint256 amountToBurn = destUSDCSupply - 100;
        deal(SRC_USDC, address(srcUSDCBridge), amountToBurn);
        assertEq(FiatTokenV2_2(SRC_USDC).balanceOf(address(srcUSDCBridge)), amountToBurn, "Bridge should have USDC to burn");
        SourceOFTAdapter(address(srcUSDCBridge)).burnLockedUSDC();
        assertEq(FiatTokenV2_2(SRC_USDC).balanceOf(address(srcUSDCBridge)), 0, "Circle should be able to burn locked USDC");
    }
}
