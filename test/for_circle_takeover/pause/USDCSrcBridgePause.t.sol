// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {USDCSrcBridgePrepareTakeoverTestBase, USDCSrcBridgePrepareTakeover} from "../prepare_takeover/base/USDCSrcBridgePrepareTakeoverBase.t.sol";
import {SourceOFTAdapter} from "../../../src/upgrade_to_before_circle_takeover/SourceOFTAdapterForTakeover.sol";
import {USDCSrcBridgePause} from "../../../script/for_circle_takeover/pause/USDCSrcBridgePause.s.sol";
import "forge-std/console.sol";

contract USDCSrcBridgePauseTest is USDCSrcBridgePrepareTakeoverTestBase, USDCSrcBridgePause {
    function setUp() public override (USDCSrcBridgePrepareTakeoverTestBase, USDCSrcBridgePause) {
        USDCSrcBridgePrepareTakeoverTestBase.setUp();
    }

    function run() public override (USDCSrcBridgePrepareTakeover, USDCSrcBridgePause) {}

    function testPause() public {
        vm.selectFork(ethForkId);
        vm.startPrank(mockEthUSDCBridgeOwner);
        USDCSrcBridgePause._run(false, address(ethUSDCBridge));
        assertTrue(SourceOFTAdapter(address(ethUSDCBridge)).paused(), "Bridge should be paused");
    }
}