// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfigSetup} from "../ConfigSetup.s.sol";
import "forge-std/console.sol";
import {MasterMinter} from "../../src/interfaces/IMasterMinter.sol";

contract USDCSetBridgeAsMinter is ConfigSetup {
    function setUp() public virtual {
        loadUSDCConfig({isBridgeDeployed: true});
    }

    // Should be called by `MASTER_MINTER_OWNER_ADDRESS` in `.env.citrea-usdc`
    function run() public {
        vm.createSelectFork(destRPC);
        _run(true, msg.sender, destMM, destUSDCBridgeProxy);
    }

    function _run(bool broadcast, address _controller, address _destMM, address _destUSDCBridgeProxy) public {
        if (broadcast) vm.startBroadcast();
        MasterMinter(_destMM).configureController(_controller, address(_destUSDCBridgeProxy));
        MasterMinter(_destMM).configureMinter(type(uint256).max);
        if (broadcast) vm.stopBroadcast();
    }
}