// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import { MasterMinter } from "../src/interfaces/IMasterMinter.sol";

contract USDCRemoveBridgeAsMinter is Script {
    function run() public {
        address citreaMM = vm.envAddress("CITREA_MM");
        string memory citreaRPC = vm.envString("CITREA_RPC");

        vm.createSelectFork(citreaRPC);
        vm.startBroadcast();

        // MasterMinter in turn removes the bridge as a minter from USDC directly so this step is necessary.
        MasterMinter(citreaMM).removeMinter();
        // This step is not strictly necessary as our MasterMinter will detach from Citrea USDC for takeover
        // and the controller is a MasterMinter specific logic. Regardless, having this step makes it a full reversion of the steps in the deploy script.
        MasterMinter(citreaMM).removeController(msg.sender);

        vm.stopBroadcast();
    }
}