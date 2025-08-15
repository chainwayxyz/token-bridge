// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfigSetup} from "../../ConfigSetup.s.sol";
import "forge-std/console.sol";

interface IOFTExtension {
    function setOFTContract(address _oftContract) external;
}

contract USDTSetBridgeAsMinter is ConfigSetup {
    function setUp() public virtual {
        loadUSDTConfig({isUSDTDeployed: true, isBridgeDeployed: true});
    }

    // Should be called by `dest.usdt.init.owner` address
    function run() public {
        vm.createSelectFork(destRPC);
        _run(true, destUSDT, destUSDTBridgeProxy);
    }

    function _run(bool broadcast, address _destUSDT, address _destUSDTBridgeProxy) public {
        if (broadcast) vm.startBroadcast();
        // Set the bridge as crosschain minter and burner
        IOFTExtension(_destUSDT).setOFTContract(_destUSDTBridgeProxy);
        if (broadcast) vm.stopBroadcast();
    }
}