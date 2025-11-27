// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfigSetup} from "../../ConfigSetup.s.sol";
import {WBTCOFTAdapter} from "../../../src/wbtc/WBTCOFTAdapter.sol";
import {WBTCOFT} from "../../../src/wbtc/WBTCOFT.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "forge-std/console.sol";

contract WBTCAndBridgeAssignRoles is ConfigSetup {
    function setUp() public virtual {
        loadWBTCConfig({isBridgeDeployed: true});
    }

    // Should be called by deployer
    function run() public {
        vm.createSelectFork(srcRPC);
        _runSrc(true, srcWBTCBridge, srcWBTCBridgeOwner);
        vm.createSelectFork(destRPC);
        _runDest(true, destWBTCBridge, destWBTCBridgeOwner);
    }

    function _runSrc(bool broadcast, address _srcWBTCBridge, address _srcWBTCBridgeOwner) public {
        if (broadcast) vm.startBroadcast();
        WBTCOFTAdapter(_srcWBTCBridge).setDelegate(_srcWBTCBridgeOwner);
        WBTCOFTAdapter(_srcWBTCBridge).transferOwnership(_srcWBTCBridgeOwner);
        console.log("Source WBTC Bridge Owner and Delegate set to:", _srcWBTCBridgeOwner);
        if (broadcast) vm.stopBroadcast();
    }

    function _runDest(
        bool broadcast,
        address _destWBTCBridge,
        address _destWBTCBridgeOwner
    ) public {
        if (broadcast) vm.startBroadcast();
        WBTCOFT(_destWBTCBridge).setDelegate(_destWBTCBridgeOwner);
        WBTCOFT(_destWBTCBridge).setFeeOwner(_destWBTCBridgeOwner);
        WBTCOFT(_destWBTCBridge).transferOwnership(_destWBTCBridgeOwner);
        console.log("Destination WBTC Bridge Owner and Delegate set to:", _destWBTCBridgeOwner);
        if (broadcast) vm.stopBroadcast();
    }
}
