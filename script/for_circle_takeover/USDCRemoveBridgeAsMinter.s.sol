// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfigSetup} from "../ConfigSetup.s.sol";
import { MasterMinter } from "../../src/interfaces/IMasterMinter.sol";

contract USDCRemoveBridgeAsMinter is ConfigSetup {
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
        // MasterMinter in turn removes the bridge as a minter from USDC directly so this step is necessary.
        MasterMinter(citreaMM).removeMinter();
        // This step is not strictly necessary as our MasterMinter will detach from Citrea USDC for takeover
        // and the controller is a MasterMinter specific logic. Regardless, having this step makes it a full reversion of the steps in the deploy script.
        MasterMinter(citreaMM).removeController(msg.sender);
        if (broadcast) vm.stopBroadcast();
    }
}