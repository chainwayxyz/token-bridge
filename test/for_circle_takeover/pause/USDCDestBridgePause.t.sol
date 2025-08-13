// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {USDCDestBridgePrepareTakeoverTestBase, USDCDestBridgePrepareTakeover} from "../prepare_takeover/base/USDCDestBridgePrepareTakeoverBase.t.sol";
import {DestinationOUSDC} from "../../../src/upgrade_to_before_circle_takeover/DestinationOUSDCForTakeover.sol";
import {USDCDestBridgePause} from "../../../script/for_circle_takeover/pause/USDCDestBridgePause.s.sol";
import "forge-std/console.sol";

contract USDCDestBridgePauseTest is USDCDestBridgePrepareTakeoverTestBase, USDCDestBridgePause {
    function setUp() public override (USDCDestBridgePrepareTakeoverTestBase, USDCDestBridgePause) {
        USDCDestBridgePrepareTakeoverTestBase.setUp();
    }

    function run() public override (USDCDestBridgePrepareTakeover, USDCDestBridgePause) {}

    function testPause() public {
        vm.selectFork(destForkId);
        vm.startPrank(mockDestUSDCBridgeOwner);
        USDCDestBridgePause._run(false, address(destUSDCBridge));
        assertTrue(DestinationOUSDC(address(destUSDCBridge)).paused(), "Bridge should be paused");
    }
}