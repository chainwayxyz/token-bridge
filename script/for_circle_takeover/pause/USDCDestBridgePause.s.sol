// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {DestinationOUSDC} from "../../../src/upgrade_to_before_circle_takeover/DestinationOUSDCForTakeover.sol";
import {ConfigSetup} from "../../ConfigSetup.s.sol";
import "forge-std/console.sol";

contract USDCDestBridgePause is ConfigSetup {
    function setUp() public virtual {
        loadUSDCConfig({isBridgeDeployed: true});
    }

    // Should be called by `citrea.usdc.bridge.deployment.init.owner` address
    function run() public virtual {
        vm.createSelectFork(citreaRPC);
        _run(true, citreaUSDCBridgeProxy);
    }

    function _run(bool broadcast, address _citreaUSDCBridgeProxy) public {
        if (broadcast) vm.startBroadcast();
        DestinationOUSDC citreaUSDCBridge = DestinationOUSDC(_citreaUSDCBridgeProxy);
        citreaUSDCBridge.pause();
        console.log("Paused Citrea USDC Bridge at:", address(citreaUSDCBridge));
        if (broadcast) vm.stopBroadcast();
    }
}
