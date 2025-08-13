// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {USDCSrcBridgePrepareTakeoverTestBase, ERC1967Utils} from "./base/USDCSrcBridgePrepareTakeoverBase.t.sol";
import {SourceOFTAdapter} from "../../../src/upgrade_to_before_circle_takeover/SourceOFTAdapterForTakeover.sol";
import "forge-std/console.sol";

contract USDCSrcBridgePrepareTakeoverTest is USDCSrcBridgePrepareTakeoverTestBase {
    function setUp() public override {
        super.setUp();
    }
    
    function testPrepareTakeover() public {
        vm.selectFork(srcForkId);
        vm.startPrank(mockSrcUSDCBridgeOwner);
        SourceOFTAdapter(address(srcUSDCBridge)).pause();
        assertTrue(SourceOFTAdapter(address(srcUSDCBridge)).paused(), "Bridge should be paused");
    }
}
