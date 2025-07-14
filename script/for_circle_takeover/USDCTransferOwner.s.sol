// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfigSetup} from "./ConfigSetup.s.sol";
import "../src/USDCRolesHolder.sol";
import { FiatTokenV2_2 } from "../src/interfaces/IFiatTokenV2_2.sol";

contract USDCTransferOwner is ConfigSetup {
    function setUp() public {
        loadUSDCConfig({isBridgeDeployed: true});
    }

    function run() public {
        address usdcRolesHolderOwner = vm.envAddress("USDC_ROLES_HOLDER_OWNER");

        vm.createSelectFork(citreaRPC);
        vm.startBroadcast();
        USDCRolesHolder usdcRolesHolder = new USDCRolesHolder(usdcRolesHolderOwner, citreaUSDC);
        FiatTokenV2_2(citreaUSDC).transferOwnership(address(usdcRolesHolder));
        vm.stopBroadcast();
    }
}