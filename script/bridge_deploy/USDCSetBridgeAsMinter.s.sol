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
        vm.createSelectFork(citreaRPC);
        _run(true, msg.sender, citreaMM, citreaUSDCBridgeProxy);
    }

    function _run(bool broadcast, address _controller, address _citreaMM, address _citreaUSDCBridgeProxy) public {
        if (broadcast) vm.startBroadcast();
        MasterMinter(_citreaMM).configureController(_controller, address(_citreaUSDCBridgeProxy));
        MasterMinter(_citreaMM).configureMinter(type(uint256).max);
        if (broadcast) vm.stopBroadcast();
    }
}