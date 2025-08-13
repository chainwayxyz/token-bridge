// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {USDCSrcBridgePrepareTakeoverTestBase, USDCSrcBridgePrepareTakeover} from "../prepare_takeover/base/USDCSrcBridgePrepareTakeoverBase.t.sol";
import {SourceOFTAdapter} from "../../../src/upgrade_to_before_circle_takeover/SourceOFTAdapterForTakeover.sol";
import {USDCSrcBridgeUnpause} from "../../../script/for_circle_takeover/pause/USDCSrcBridgeUnpause.s.sol";
import "forge-std/console.sol";

contract USDCSrcBridgeUnpauseTest is USDCSrcBridgePrepareTakeoverTestBase, USDCSrcBridgeUnpause {
    function setUp() public override (USDCSrcBridgePrepareTakeoverTestBase, USDCSrcBridgeUnpause) {
        USDCSrcBridgePrepareTakeoverTestBase.setUp();
    }

    function run() public override (USDCSrcBridgePrepareTakeover, USDCSrcBridgeUnpause) {}

    function testUnpause() public {
        vm.selectFork(ethForkId);
        vm.startPrank(mockEthUSDCBridgeOwner);
        SourceOFTAdapter(address(ethUSDCBridge)).pause();
        assertTrue(SourceOFTAdapter(address(ethUSDCBridge)).paused(), "Bridge should be paused");
        USDCSrcBridgeUnpause._run(false, address(ethUSDCBridge));
        assertFalse(SourceOFTAdapter(address(ethUSDCBridge)).paused(), "Bridge should be unpaused");
    }
}