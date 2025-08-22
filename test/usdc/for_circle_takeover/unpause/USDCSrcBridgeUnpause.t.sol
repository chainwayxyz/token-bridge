// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {USDCSrcBridgePrepareTakeoverTestBase, USDCSrcBridgePrepareTakeover} from "../base/USDCSrcBridgePrepareTakeoverBase.t.sol";
import {SourceOFTAdapter} from "../../../../src/for_circle_takeover/SourceOFTAdapterForTakeover.sol";
import {USDCSrcBridgeUnpause} from "../../../../script/usdc/for_circle_takeover/unpause/USDCSrcBridgeUnpause.s.sol";
import "forge-std/console.sol";

contract USDCSrcBridgeUnpauseTest is USDCSrcBridgePrepareTakeoverTestBase, USDCSrcBridgeUnpause {
    function setUp() public override (USDCSrcBridgePrepareTakeoverTestBase, USDCSrcBridgeUnpause) {
        USDCSrcBridgePrepareTakeoverTestBase.setUp();
    }

    function run() public override (USDCSrcBridgePrepareTakeover, USDCSrcBridgeUnpause) {}

    function testUnpause() public {
        vm.selectFork(srcForkId);
        vm.startPrank(mockSrcUSDCBridgeOwner);
        SourceOFTAdapter(address(srcUSDCBridge)).pause();
        assertTrue(SourceOFTAdapter(address(srcUSDCBridge)).paused(), "Bridge should be paused");
        USDCSrcBridgeUnpause._run(false, address(srcUSDCBridge));
        assertFalse(SourceOFTAdapter(address(srcUSDCBridge)).paused(), "Bridge should be unpaused");
    }
}