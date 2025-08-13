// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {DestinationOUSDC} from "../../../src/upgrade_to_before_circle_takeover/DestinationOUSDCForTakeover.sol";
import {ConfigSetup} from "../../ConfigSetup.s.sol";
import "forge-std/console.sol";

contract USDCDestBridgePause is ConfigSetup {
    function setUp() public virtual {
        loadUSDCConfig({isBridgeDeployed: true});
    }

    // Should be called by `dest.usdc.bridge.deployment.init.owner` address
    function run() public virtual {
        vm.createSelectFork(destRPC);
        _run(true, destUSDCBridgeProxy);
    }

    function _run(bool broadcast, address _destUSDCBridgeProxy) public {
        if (broadcast) vm.startBroadcast();
        DestinationOUSDC destUSDCBridge = DestinationOUSDC(_destUSDCBridgeProxy);
        destUSDCBridge.pause();
        console.log("Paused Destination USDC Bridge at:", address(destUSDCBridge));
        if (broadcast) vm.stopBroadcast();
    }
}
