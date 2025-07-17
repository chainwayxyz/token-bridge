// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {USDCRolesHolder} from "../../../src/USDCRolesHolder.sol";
import {ConfigSetup, FiatTokenV2_2} from "../ConfigSetup.s.sol";
import "forge-std/console.sol";

contract USDCRolesHolderSetCircle is ConfigSetup {
    function setUp() public {
        loadUSDCConfig({isBridgeDeployed: true});
    }

    // Should be called by `owner` of `USDC_ROLES_HOLDER` address
    function run() public {
        vm.createSelectFork(ethRPC);
        vm.startBroadcast();

        USDCRolesHolder usdcRolesHolder = USDCRolesHolder(FiatTokenV2_2(citreaUSDC).owner());
        address circle = vm.envAddress("USDC_ROLES_HOLDER_CIRCLE_ADDRESS");
        usdcRolesHolder.setCircle(circle);
        console.log("Set Circle address %s to USDC Roles Holder at %s.", circle, address(usdcRolesHolder));

        vm.stopBroadcast();
    }
}