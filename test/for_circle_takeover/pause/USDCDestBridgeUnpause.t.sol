// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {USDCDestBridgePrepareTakeoverTestBase, USDCDestBridgePrepareTakeover} from "../prepare_takeover/base/USDCDestBridgePrepareTakeoverBase.t.sol";
import {DestinationOUSDC} from "../../../src/upgrade_to_before_circle_takeover/DestinationOUSDCForTakeover.sol";
import {USDCDestBridgeUnpause} from "../../../script/for_circle_takeover/pause/USDCDestBridgeUnpause.s.sol";
import "forge-std/console.sol";

contract USDCDestBridgeUnpauseTest is USDCDestBridgePrepareTakeoverTestBase, USDCDestBridgeUnpause {
    function setUp() public override (USDCDestBridgePrepareTakeoverTestBase, USDCDestBridgeUnpause) {
        USDCDestBridgePrepareTakeoverTestBase.setUp();
    }

    function run() public override (USDCDestBridgePrepareTakeover, USDCDestBridgeUnpause) {}

    function testUnpause() public {
        vm.selectFork(destForkId);
        vm.startPrank(mockDestUSDCBridgeOwner);
        DestinationOUSDC(address(destUSDCBridge)).pause();
        assertTrue(DestinationOUSDC(address(destUSDCBridge)).paused(), "Bridge should be paused");
        USDCDestBridgeUnpause._run(false, address(destUSDCBridge));
        assertFalse(DestinationOUSDC(address(destUSDCBridge)).paused(), "Bridge should be unpaused");
    }
}