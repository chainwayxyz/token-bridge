// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {WBTCBridgeDeployTestBase} from "./base/WBTCBridgeDeployBase.t.sol";
import {WBTCOFT} from "../../../src/wbtc/WBTCOFT.sol";

contract WBTCDestBridgeDeployTest is WBTCBridgeDeployTestBase {
    function testName() public {
        vm.selectFork(destForkId);
        assertEq(destWBTCBridge_.name(), "Bridged WBTC (Dest)", "WBTC name should match");
    }

    function testSymbol() public {
        vm.selectFork(destForkId);
        assertEq(destWBTCBridge_.symbol(), "WBTC.e", "WBTC symbol should match");
    }

    function testDecimals() public {
        vm.selectFork(destForkId);
        assertEq(destWBTCBridge_.decimals(), 8, "WBTC decimals should be 8");
    }

    function testSharedDecimals() public {
        vm.selectFork(destForkId);
        assertEq(destWBTCBridge_.sharedDecimals(), 8, "WBTC shared decimals should be 8");
    }

    function testBridgeOwner() public {
        vm.selectFork(destForkId);
        assertEq(destWBTCBridge_.owner(), deployer, "Owner should be set to deployer initially");
    }

    function testBridgeFeeOwner() public {
        vm.selectFork(destForkId);
        assertEq(destWBTCBridge_.feeOwner(), deployer, "Fee Owner should be set to deployer initially");
    }
}
