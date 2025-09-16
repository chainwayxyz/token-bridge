// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfigSetup} from "../../ConfigSetup.s.sol";
import {SourceOFTAdapter} from "../../../src/SourceOFTAdapter.sol";
import {DestinationOUSDT, IOFTToken} from "../../../src/DestinationOUSDT.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "forge-std/console.sol";

contract USDTAndBridgeAssignRoles is ConfigSetup {
    function setUp() public virtual {
        loadUSDTConfig({isUSDTDeployed: true, isBridgeDeployed: true});
    }

    // Should be called by deployer
    function run() public {
        vm.createSelectFork(srcRPC);
        _runSrc(true, srcUSDTBridgeProxy, srcUSDTBridgeOwner);
        vm.createSelectFork(destRPC);
        _runDest(true, destUSDT, destUSDTBridgeProxy, destUSDTOwner, destUSDTBridgeOwner);
    }

    function _runSrc(bool broadcast, address _srcUSDTBridgeProxy, address _srcUSDTBridgeOwner) public {
        if (broadcast) vm.startBroadcast();
        SourceOFTAdapter(_srcUSDTBridgeProxy).setDelegate(_srcUSDTBridgeOwner);
        SourceOFTAdapter(_srcUSDTBridgeProxy).transferOwnership(_srcUSDTBridgeOwner);
        console.log("Source USDT Bridge Owner and Delegate set to:", _srcUSDTBridgeOwner);
        if (broadcast) vm.stopBroadcast();
    }

    function _runDest(
        bool broadcast,
        address _destUSDT,
        address _destUSDTBridgeProxy,
        address _destUSDTOwner,
        address _destUSDTBridgeOwner
    ) public {
        if (broadcast) vm.startBroadcast();
        DestinationOUSDT(_destUSDTBridgeProxy).setDelegate(_destUSDTBridgeOwner);
        DestinationOUSDT(_destUSDTBridgeProxy).transferOwnership(_destUSDTBridgeOwner);
        console.log("Destination USDT Bridge Owner and Delegate set to:", _destUSDTBridgeOwner);
        Ownable(_destUSDT).transferOwnership(_destUSDTOwner);
        console.log("Destination USDT Owner set to:", _destUSDTOwner);
        if (broadcast) vm.stopBroadcast();
    }
}