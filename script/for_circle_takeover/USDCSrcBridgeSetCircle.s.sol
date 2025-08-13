// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {SourceOFTAdapter} from "../../src/upgrade_to_before_circle_takeover/SourceOFTAdapterForTakeover.sol";
import {ConfigSetup} from "../ConfigSetup.s.sol";
import "forge-std/console.sol";

contract USDCSrcBridgeSetCircle is ConfigSetup {
    function setUp() public virtual {
        loadUSDCConfig({isBridgeDeployed: true});
    }

    // Should be called by `src.usdc.bridge.deployment.init.owner` address
    function run() public virtual {
        vm.createSelectFork(srcRPC);
        _run(true, srcUSDCBridgeProxy, vm.envAddress("SRC_BRIDGE_CIRCLE_ADDRESS"));
    }

    function _run(bool broadcast, address _srcUSDCBridgeProxy, address _circle) public {
        if (broadcast) vm.startBroadcast();
        SourceOFTAdapter srcUSDCBridge = SourceOFTAdapter(_srcUSDCBridgeProxy);
        srcUSDCBridge.setCircle(_circle);
        console.log("Set Circle address %s to Source USDC Bridge at %s.", _circle, address(srcUSDCBridge));
        if (broadcast) vm.stopBroadcast();
    }
}