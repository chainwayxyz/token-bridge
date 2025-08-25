// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./base/USDCSrcBridgePrepareTakeoverBase.t.sol";
import {USDCSrcBridgeSetCircle} from "../../../script/usdc/for_circle_takeover/08_USDCSrcBridgeSetCircle.s.sol";
import {MasterMinter} from "../../../src/interfaces/IMasterMinter.sol";

contract USDCSrcBridgeSetCircleTest is USDCSrcBridgePrepareTakeoverTestBase, USDCSrcBridgeSetCircle {
    function setUp() public override (USDCSrcBridgeSetCircle, USDCSrcBridgePrepareTakeoverTestBase) {
        USDCSrcBridgePrepareTakeoverTestBase.setUp();
    }

    function run() public override (USDCSrcBridgeSetCircle, USDCSrcBridgePrepareTakeover) {}

    function testSetCircle() public {
        vm.selectFork(srcForkId);
        vm.startPrank(srcUSDCBridge.owner());
        address circle = makeAddr("CIRCLE_ADDRESS");
        USDCSrcBridgeSetCircle._run(false, address(srcUSDCBridge), circle);
        assertEq(SourceOFTAdapter(address(srcUSDCBridge)).circle(), circle, "Circle address should be set correctly");
    }

    function testCircleCanBurnLockedUSDC() public {
        vm.selectFork(srcForkId);
        vm.startPrank(srcUSDCBridge.owner());
        address circle = makeAddr("CIRCLE_ADDRESS");
        USDCSrcBridgeSetCircle._run(false, address(srcUSDCBridge), circle);
        vm.stopPrank();

        // Circle should set `srcUSDCBridge` as a zero-allowance minter on Source USDC so that it can burn its balance
        MasterMinter srcMM = MasterMinter(FiatTokenV2_2(SRC_USDC).masterMinter());
        address srcMMOwner = srcMM.owner();
        vm.startPrank(srcMMOwner);
        srcMM.configureController(srcMMOwner, address(srcUSDCBridge));
        srcMM.configureMinter(0);
        vm.stopPrank();

        vm.startPrank(circle);
        uint256 amountToBurn = 1000;
        deal(SRC_USDC, address(srcUSDCBridge), amountToBurn); // Give bridge some USDC
        assertEq(FiatTokenV2_2(SRC_USDC).balanceOf(address(srcUSDCBridge)), amountToBurn, "Bridge should have USDC to burn");
        SourceOFTAdapter(address(srcUSDCBridge)).burnLockedUSDC();
        assertEq(FiatTokenV2_2(SRC_USDC).balanceOf(circle), 0, "Circle should be able to burn locked USDC");
    }
}
