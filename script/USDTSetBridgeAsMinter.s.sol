// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfigSetup} from "./ConfigSetup.s.sol";
import "forge-std/console.sol";

interface IOFTExtension {
    function setOFTContract(address _oftContract) external;
}

contract USDTSetBridgeAsMinter is ConfigSetup {
    function setUp() public {
        loadUSDTConfig({isUSDTDeployed: true, isBridgeDeployed: true});
    }

    // Should be called by the owner of Citrea USDT (`citreaUSDTOwner`)
    function run() public {
        vm.createSelectFork(citreaRPC);
        vm.startBroadcast();

        // Set the bridge as crosschain minter and burner
        IOFTExtension(citreaUSDT).setOFTContract(citreaUSDTBridgeProxy);

        vm.stopBroadcast();
    }
}