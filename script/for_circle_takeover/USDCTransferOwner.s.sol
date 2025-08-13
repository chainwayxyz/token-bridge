// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfigSetup} from "../ConfigSetup.s.sol";
import "../../src/USDCRolesHolder.sol";
import { FiatTokenV2_2 } from "../../src/interfaces/IFiatTokenV2_2.sol";
import "forge-std/console.sol";

contract USDCTransferOwner is ConfigSetup {
    function setUp() public virtual {
        loadUSDCConfig({isBridgeDeployed: true});
    }

    // Should be called by `citrea.usdc.bridge.init.owner` address
    function run() public virtual {
        vm.createSelectFork(citreaRPC);
        _run_(true, vm.envAddress("USDC_ROLES_HOLDER_OWNER"), address(citreaUSDC));
    }

    // @dev Used `_run_` to avoid name clash with `_run` function from `USDCRolesHolderSetCircle` contract in unit tests.
    function _run_(bool broadcast, address _usdcRolesHolderOwner, address _citreaUSDC) public virtual returns (address) {
        if (broadcast) vm.startBroadcast();
        USDCRolesHolder usdcRolesHolder = new USDCRolesHolder(_usdcRolesHolderOwner, _citreaUSDC);
        console.log("Created USDC Roles Holder at %s with owner %s.", address(usdcRolesHolder), _usdcRolesHolderOwner);
        FiatTokenV2_2(_citreaUSDC).transferOwnership(address(usdcRolesHolder));
        if (broadcast) vm.stopBroadcast();
        return address(usdcRolesHolder);
    }
}