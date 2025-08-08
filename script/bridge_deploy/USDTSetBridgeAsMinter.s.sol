// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfigSetup} from "../ConfigSetup.s.sol";
import "forge-std/console.sol";

interface IOFTExtension {
    function setOFTContract(address _oftContract) external;
}

contract USDTSetBridgeAsMinter is ConfigSetup {
    function setUp() public virtual {
        loadUSDTConfig({isUSDTDeployed: true, isBridgeDeployed: true});
    }

    // Should be called by `citrea.usdt.init.owner` address
    function run() public {
        vm.createSelectFork(citreaRPC);
        _run(true, citreaUSDT, citreaUSDTBridgeProxy);
    }

    function _run(bool broadcast, address _citreaUSDT, address _citreaUSDTBridgeProxy) public {
        if (broadcast) vm.startBroadcast();
        // Set the bridge as crosschain minter and burner
        IOFTExtension(_citreaUSDT).setOFTContract(_citreaUSDTBridgeProxy);
        if (broadcast) vm.stopBroadcast();
    }
}