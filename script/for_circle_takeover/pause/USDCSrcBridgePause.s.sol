// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {SourceOFTAdapter} from "../../../src/upgrade_to_before_circle_takeover/SourceOFTAdapterForTakeover.sol";
import {ConfigSetup} from "../../ConfigSetup.s.sol";
import "forge-std/console.sol";

contract USDCSrcBridgePause is ConfigSetup {
    function setUp() public {
        loadUSDCConfig({isBridgeDeployed: true});
    }

    // Should be called by `eth.usdc.bridge.deployment.init.owner` address
    function run() public {
        vm.createSelectFork(ethRPC);
        vm.startBroadcast();

        SourceOFTAdapter ethUSDCBridge = SourceOFTAdapter(ethUSDCBridgeProxy);
        ethUSDCBridge.pause();
        console.log("Paused Ethereum USDC Bridge at:", address(ethUSDCBridge));

        vm.stopBroadcast();
    }

    function _run(bool broadcast) public {
        if (broadcast) vm.startBroadcast();
        SourceOFTAdapter ethUSDCBridge = SourceOFTAdapter(ethUSDCBridgeProxy);
        ethUSDCBridge.pause();
        console.log("Paused Ethereum USDC Bridge at:", address(ethUSDCBridge));
        if (broadcast) vm.stopBroadcast();
    }
}
