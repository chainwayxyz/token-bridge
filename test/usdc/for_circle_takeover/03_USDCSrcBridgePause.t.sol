// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {USDCSrcBridgePrepareTakeoverTestBase, USDCSrcBridgePrepareTakeover} from "../for_circle_takeover/base/USDCSrcBridgePrepareTakeoverBase.t.sol";
import {SourceOFTAdapter} from "../../../src/for_circle_takeover/SourceOFTAdapterForTakeover.sol";
import {USDCSrcBridgePause} from "../../../script/usdc/for_circle_takeover/03_USDCSrcBridgePause.s.sol";
import "forge-std/console.sol";

contract USDCSrcBridgePauseTest is USDCSrcBridgePrepareTakeoverTestBase, USDCSrcBridgePause {
    function setUp() public override (USDCSrcBridgePrepareTakeoverTestBase, USDCSrcBridgePause) {
        USDCSrcBridgePrepareTakeoverTestBase.setUp();
    }

    function run() public override (USDCSrcBridgePrepareTakeover, USDCSrcBridgePause) {}

    function testPause() public {
        vm.selectFork(srcForkId);
        vm.startPrank(mockSrcUSDCBridgeOwner);
        USDCSrcBridgePause._run(false, address(srcUSDCBridge));
        assertTrue(SourceOFTAdapter(address(srcUSDCBridge)).paused(), "Bridge should be paused");
    }
}