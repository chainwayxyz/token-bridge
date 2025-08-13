// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {USDCRolesHolder} from "../../src/USDCRolesHolder.sol";
import {ConfigSetup, FiatTokenV2_2} from "../ConfigSetup.s.sol";
import "forge-std/console.sol";

contract USDCRolesHolderSetCircle is ConfigSetup {
    function setUp() public virtual {
        loadUSDCConfig({isBridgeDeployed: true});
    }

    // Should be called by `owner` of `USDC_ROLES_HOLDER` address
    function run() public virtual {
        vm.createSelectFork(destRPC);
        _run(true, address(destUSDC), vm.envAddress("USDC_ROLES_HOLDER_CIRCLE_ADDRESS"));
    }

    function _run(bool broadcast, address _destUSDC, address _circle) public virtual {
        if (broadcast) vm.startBroadcast();
        USDCRolesHolder usdcRolesHolder = USDCRolesHolder(FiatTokenV2_2(_destUSDC).owner());
        usdcRolesHolder.setCircle(_circle);
        console.log("Set Circle address %s to USDC Roles Holder at %s.", _circle, address(usdcRolesHolder));
        if (broadcast) vm.stopBroadcast();
    }
}