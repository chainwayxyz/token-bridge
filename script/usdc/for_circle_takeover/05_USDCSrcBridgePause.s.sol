// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {SourceOFTAdapter} from "../../../src/for_circle_takeover/SourceOFTAdapterForTakeover.sol";
import {ConfigSetup} from "../../ConfigSetup.s.sol";
import "forge-std/console.sol";

contract USDCSrcBridgePause is ConfigSetup {
    function setUp() public virtual {
        loadUSDCConfig({isBridgeDeployed: true});
    }

    // Should be called by `src.usdc.bridge.deployment.init.owner` address
    function run() public virtual {
        // Call InflightMsgCheckLzScan.sh to ensure there are no `INFLIGHT` or `CONFIRMING` messages
        _checkInflightMessages();
        vm.createSelectFork(srcRPC);
        _run(true, srcUSDCBridgeProxy);
    }

    function _run(bool broadcast, address _srcUSDCBridgeProxy) public {
        if (broadcast) vm.startBroadcast();
        SourceOFTAdapter srcUSDCBridge = SourceOFTAdapter(_srcUSDCBridgeProxy);
        srcUSDCBridge.pause();
        console.log("Paused Source USDC Bridge at:", address(srcUSDCBridge));
        if (broadcast) vm.stopBroadcast();
    }

    function _checkInflightMessages() internal {
        string[] memory cmd = new string[](2);
        cmd[0] = "sh";
        cmd[1] = "script/usdc/for_circle_takeover/InflightMsgCheckLzScan.sh";
        bytes memory res = vm.ffi(cmd);
        string memory output = string(res);
        require(keccak256(abi.encodePacked(output)) == keccak256(abi.encodePacked("SUCCESS: All checks passed.")));
    }
}
