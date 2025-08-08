// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {SourceOFTAdapter} from "../../../src/upgrade_to_before_circle_takeover/SourceOFTAdapterForTakeover.sol";
import {ConfigSetup} from "../../ConfigSetup.s.sol";
import "forge-std/console.sol";

contract USDCSrcBridgePause is ConfigSetup {
    function setUp() public virtual {
        loadUSDCConfig({isBridgeDeployed: true});
    }

    // Should be called by `eth.usdc.bridge.deployment.init.owner` address
    function run() public virtual {
        vm.createSelectFork(ethRPC);
        _run(true, ethUSDCBridgeProxy);
    }

    function _run(bool broadcast, address _ethUSDCBridgeProxy) public {
        if (broadcast) vm.startBroadcast();
        SourceOFTAdapter ethUSDCBridge = SourceOFTAdapter(_ethUSDCBridgeProxy);
        ethUSDCBridge.pause();
        console.log("Paused Ethereum USDC Bridge at:", address(ethUSDCBridge));
        if (broadcast) vm.stopBroadcast();
    }
}
