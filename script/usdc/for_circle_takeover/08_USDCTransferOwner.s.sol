// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfigSetup} from "../../ConfigSetup.s.sol";
import "../../../src/USDCRolesHolder.sol";
import { FiatTokenV2_2 } from "../../../src/interfaces/IFiatTokenV2_2.sol";
import "forge-std/console.sol";

contract USDCTransferOwner is ConfigSetup {
    function setUp() public virtual {
        loadUSDCConfig({isBridgeDeployed: true});
    }

    // Should be called by `dest.usdc.bridge.init.owner` address
    function run() public virtual {
        vm.createSelectFork(destRPC);
        _run_(true, vm.envAddress("USDC_ROLES_HOLDER_OWNER"), address(destUSDC));
    }

    // @dev Used `_run_` to avoid name clash with `_run` function from `USDCRolesHolderSetCircle` contract in unit tests.
    function _run_(bool broadcast, address _usdcRolesHolderOwner, address _destUSDC) public virtual returns (address) {
        if (broadcast) vm.startBroadcast();
        USDCRolesHolder usdcRolesHolder = new USDCRolesHolder(_usdcRolesHolderOwner, _destUSDC);
        console.log("Created USDC Roles Holder at %s with owner %s.", address(usdcRolesHolder), _usdcRolesHolderOwner);
        FiatTokenV2_2(_destUSDC).transferOwnership(address(usdcRolesHolder));
        if (broadcast) vm.stopBroadcast();
        return address(usdcRolesHolder);
    }
}