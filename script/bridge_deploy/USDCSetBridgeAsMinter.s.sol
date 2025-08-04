// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfigSetup} from "../ConfigSetup.s.sol";
import "forge-std/console.sol";
import {MasterMinter} from "../../src/interfaces/IMasterMinter.sol";

contract USDCSetBridgeAsMinter is ConfigSetup {
    function setUp() public {
        loadUSDCConfig({isBridgeDeployed: true});
    }

    // Should be called by `MASTER_MINTER_OWNER_ADDRESS` in `.env.citrea-usdc`
    function run() public {
        vm.createSelectFork(citreaRPC);
        _run(true);
    }

    function _run(bool broadcast) public {
        if (broadcast) vm.startBroadcast();
        MasterMinter(citreaMM).configureController(msg.sender, address(citreaUSDCBridgeProxy));
        MasterMinter(citreaMM).configureMinter(type(uint256).max);
        if (broadcast) vm.stopBroadcast();
    }
}