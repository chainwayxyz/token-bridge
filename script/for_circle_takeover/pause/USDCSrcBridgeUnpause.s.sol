// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {SourceOFTAdapter} from "../../../src/upgrade_to_before_circle_takeover/SourceOFTAdapterForTakeover.sol";
import {ConfigSetup} from "../../ConfigSetup.s.sol";
import "forge-std/console.sol";

contract USDCSrcBridgeUnpause is ConfigSetup {
    function setUp() public virtual {
        loadUSDCConfig({isBridgeDeployed: true});
    }

    // Should be called by `src.usdc.bridge.deployment.init.owner` address
    function run() public virtual {
        vm.createSelectFork(srcRPC);
        _run(true, srcUSDCBridgeProxy);
    }

    function _run(bool broadcast, address _srcUSDCBridgeProxy) public {
        if (broadcast) vm.startBroadcast();
        SourceOFTAdapter srcUSDCBridge = SourceOFTAdapter(_srcUSDCBridgeProxy);
        srcUSDCBridge.unpause();
        console.log("Unpaused Source USDC Bridge at:", address(srcUSDCBridge));
        if (broadcast) vm.stopBroadcast();
    }
}
