// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfigSetup} from "../../ConfigSetup.s.sol";
import {WBTCOFT} from "../../../src/wbtc/WBTCOFT.sol";
import "forge-std/console.sol";

contract WBTCDestBridgeDeploy is ConfigSetup {
    function setUp() public {
        loadWBTCConfig({isBridgeDeployed: false});
    }

    // Can be called by any address
    function run() public {
        vm.createSelectFork(destRPC);
        address destBridge = _run(true, destWBTCName, destWBTCSymbol, destLzEndpoint, msg.sender);
        saveAddressToConfig(".dest.wbtc.bridge.deployment.contract", destBridge);
    }

    function _run(
        bool broadcast,
        string memory _destWBTCName,
        string memory _destWBTCSymbol,
        address _destLzEndpoint,
        address _destWBTCBridgeOwner
    ) public returns (address) {
        if (broadcast) vm.startBroadcast();

        WBTCOFT destBridge = new WBTCOFT(_destWBTCName, _destWBTCSymbol, _destLzEndpoint, _destWBTCBridgeOwner);
        console.log("Destination WBTC Bridge:", address(destBridge));

        if (broadcast) vm.stopBroadcast();
        return address(destBridge);
    }
}
