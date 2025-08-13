// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {USDCDestBridgePrepareTakeoverTestBase, ERC1967Utils} from "./base/USDCDestBridgePrepareTakeoverBase.t.sol";
import {DestinationOUSDC} from "../../../src/upgrade_to_before_circle_takeover/DestinationOUSDCForTakeover.sol";
import "forge-std/console.sol";

contract USDCDestBridgePrepareTakeoverTest is USDCDestBridgePrepareTakeoverTestBase {
    function setUp() public override {
        super.setUp();
    }

    function testPrepareTakeover() public {
        vm.selectFork(destForkId);
        vm.startPrank(mockDestUSDCBridgeOwner);
        DestinationOUSDC(address(destUSDCBridge)).pause();
        assertTrue(DestinationOUSDC(address(destUSDCBridge)).paused(), "Bridge should be paused");
    }
}
