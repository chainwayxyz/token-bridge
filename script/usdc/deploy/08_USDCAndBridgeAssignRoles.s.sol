// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfigSetup} from "../../ConfigSetup.s.sol";
import {SourceOFTAdapter} from "../../../src/SourceOFTAdapter.sol";
import {DestinationOUSDC} from "../../../src/DestinationOUSDC.sol";
import {MasterMinter} from "../../../src/interfaces/IMasterMinter.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "forge-std/console.sol";

contract USDCAndBridgeAssignRoles is ConfigSetup {
    function setUp() public virtual {
        loadUSDCConfig({isBridgeDeployed: true});
    }

    // Can be called by any address
    function run() public {
        vm.createSelectFork(srcRPC);
        _runSrc(true, srcUSDCBridgeProxy, srcUSDCBridgeOwner);
        vm.createSelectFork(destRPC);
        _runDest(true, destMM, destUSDCBridgeProxy, destMMOwner, destUSDCBridgeOwner);
    }

    function _runSrc(bool broadcast, address _srcUSDCBridgeProxy, address _srcUSDCBridgeOwner) public {
        if (broadcast) vm.startBroadcast();
        SourceOFTAdapter(_srcUSDCBridgeProxy).setDelegate(_srcUSDCBridgeOwner);
        SourceOFTAdapter(_srcUSDCBridgeProxy).transferOwnership(_srcUSDCBridgeOwner);
        console.log("Source USDC Bridge Owner and Delegate set to:", _srcUSDCBridgeOwner);
        if (broadcast) vm.stopBroadcast();
    }

    function _runDest(
        bool broadcast,
        address _destMM,
        address _destUSDCBridgeProxy,
        address _destMMOwner,
        address _destUSDCBridgeOwner
    ) public {
        if (broadcast) vm.startBroadcast();
        DestinationOUSDC(_destUSDCBridgeProxy).setDelegate(_destUSDCBridgeOwner);
        DestinationOUSDC(_destUSDCBridgeProxy).transferOwnership(_destUSDCBridgeOwner);
        console.log("Destination USDC Bridge Owner and Delegate set to:", _destUSDCBridgeOwner);
        MasterMinter(_destMM).transferOwnership(_destMMOwner);
        console.log("Destination MasterMinter Owner set to:", _destMMOwner);
        if (broadcast) vm.stopBroadcast();
    }
}