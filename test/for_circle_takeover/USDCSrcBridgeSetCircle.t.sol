// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./prepare_takeover/base/USDCSrcBridgePrepareTakeoverBase.t.sol";
import {USDCSrcBridgeSetCircle} from "../../script/for_circle_takeover/USDCSrcBridgeSetCircle.s.sol";
import {MasterMinter} from "../../src/interfaces/IMasterMinter.sol";

contract USDCSrcBridgeSetCircleTest is USDCSrcBridgePrepareTakeoverTestBase, USDCSrcBridgeSetCircle {
    function setUp() public override (USDCSrcBridgeSetCircle, USDCSrcBridgePrepareTakeoverTestBase) {
        USDCSrcBridgePrepareTakeoverTestBase.setUp();
    }

    function run() public override (USDCSrcBridgeSetCircle, USDCSrcBridgePrepareTakeover) {}

    function testSetCircle() public {
        vm.selectFork(ethForkId);
        vm.startPrank(ethUSDCBridge.owner());
        address circle = makeAddr("CIRCLE_ADDRESS");
        USDCSrcBridgeSetCircle._run(false, address(ethUSDCBridge), circle);
        assertEq(SourceOFTAdapter(address(ethUSDCBridge)).circle(), circle, "Circle address should be set correctly");
    }

    function testCircleCanBurnLockedUSDC() public {
        vm.selectFork(ethForkId);
        vm.startPrank(ethUSDCBridge.owner());
        address circle = makeAddr("CIRCLE_ADDRESS");
        USDCSrcBridgeSetCircle._run(false, address(ethUSDCBridge), circle);
        vm.stopPrank();

        // Circle should set `ethUSDCBridge` as a zero-allowance minter on ETH USDC so that it can burn its balance
        MasterMinter ethMM = MasterMinter(FiatTokenV2_2(ETH_USDC).masterMinter());
        address ethMMOwner = ethMM.owner();
        vm.startPrank(ethMMOwner);
        ethMM.configureController(ethMMOwner, address(ethUSDCBridge));
        ethMM.configureMinter(0);
        vm.stopPrank();

        vm.startPrank(circle);
        uint256 amountToBurn = 1000;
        deal(ETH_USDC, address(ethUSDCBridge), amountToBurn); // Give bridge some USDC
        assertEq(FiatTokenV2_2(ETH_USDC).balanceOf(address(ethUSDCBridge)), amountToBurn, "Bridge should have USDC to burn");
        SourceOFTAdapter(address(ethUSDCBridge)).burnLockedUSDC();
        assertEq(FiatTokenV2_2(ETH_USDC).balanceOf(circle), 0, "Circle should be able to burn locked USDC");
    }
}
