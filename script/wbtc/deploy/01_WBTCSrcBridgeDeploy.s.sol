// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfigSetup} from "../../ConfigSetup.s.sol";
import {WBTCOFTAdapter} from "../../../src/wbtc/WBTCOFTAdapter.sol";
import "forge-std/console.sol";

contract WBTCSrcBridgeDeploy is ConfigSetup {
    function setUp() public {
        loadWBTCConfig({isBridgeDeployed: false});
    }

    // Can be called by any address
    function run() public {
        vm.createSelectFork(srcRPC);
        address srcBridge = _run(true, srcWBTC, srcLzEndpoint, msg.sender);
        saveAddressToConfig(".src.wbtc.bridge.deployment.contract", srcBridge);
    }

    function _run(
        bool broadcast,
        address _srcWBTC,
        address _srcLzEndpoint,
        address _srcWBTCBridgeOwner
    ) public returns (address) {
        if (broadcast) vm.startBroadcast();

        WBTCOFTAdapter srcBridge = new WBTCOFTAdapter(_srcWBTC, _srcLzEndpoint, _srcWBTCBridgeOwner);
        console.log("Source WBTC Bridge:", address(srcBridge));

        if (broadcast) vm.stopBroadcast();
        return address(srcBridge);
    }
}
