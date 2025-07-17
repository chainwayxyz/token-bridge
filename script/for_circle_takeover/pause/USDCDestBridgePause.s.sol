// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {DestinationOUSDC} from "../../../src/upgrade_to_before_circle_takeover/DestinationOUSDCForTakeover.sol";
import {ConfigSetup} from "../../ConfigSetup.s.sol";
import "forge-std/console.sol";

contract USDCDestBridgePause is ConfigSetup {
    function setUp() public {
        loadUSDCConfig({isBridgeDeployed: true});
    }

    // Should be called by `citrea.usdc.bridge.deployment.init.owner` address
    function run() public {
        vm.createSelectFork(citreaRPC);
        vm.startBroadcast();

        DestinationOUSDC citreaUSDCBridge = DestinationOUSDC(citreaUSDCBridgeProxy);
        citreaUSDCBridge.pause();
        console.log("Paused Citrea USDC Bridge at:", address(citreaUSDCBridge));

        vm.stopBroadcast();
    }
}
