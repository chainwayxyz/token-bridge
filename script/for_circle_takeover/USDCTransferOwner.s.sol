// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfigSetup} from "../ConfigSetup.s.sol";
import "../../src/USDCRolesHolder.sol";
import { FiatTokenV2_2 } from "../../src/interfaces/IFiatTokenV2_2.sol";
import "forge-std/console.sol";

contract USDCTransferOwner is ConfigSetup {
    function setUp() public {
        loadUSDCConfig({isBridgeDeployed: true});
    }

    // Should be called by `citrea.usdc.bridge.init.owner` address
    function run() public {
        address usdcRolesHolderOwner = vm.envAddress("USDC_ROLES_HOLDER_OWNER");

        vm.createSelectFork(citreaRPC);
        vm.startBroadcast();
        USDCRolesHolder usdcRolesHolder = new USDCRolesHolder(usdcRolesHolderOwner, address(citreaUSDC));
        console.log("Created USDC Roles Holder at %s with owner %s.", address(usdcRolesHolder), usdcRolesHolderOwner);
        FiatTokenV2_2(citreaUSDC).transferOwnership(address(usdcRolesHolder));

        vm.stopBroadcast();
    }
}