// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {SourceOFTAdapter} from "../../../src/for_circle_takeover/SourceOFTAdapterForTakeover.sol";
import {FiatTokenV2_2} from "../../../src/interfaces/IFiatTokenV2_2.sol";
import {ConfigSetup} from "../../ConfigSetup.s.sol";
import "forge-std/console.sol";

contract USDCSrcBridgeSetCircleAndDestSupply is ConfigSetup {
    function setUp() public virtual {
        loadUSDCConfig({isBridgeDeployed: true});
    }

    // Should be called by `src.usdc.bridge.deployment.init.owner` address
    function run() public virtual {
        vm.createSelectFork(destRPC);
        uint256 destUSDCSupply = FiatTokenV2_2(destUSDC).totalSupply();
        require(destUSDCSupply > 0, "Destination USDC total supply should be greater than zero");
        console.log("Destination USDC total supply is %s", destUSDCSupply);

        vm.createSelectFork(srcRPC);
        _run(true, srcUSDCBridgeProxy, vm.envAddress("SRC_BRIDGE_CIRCLE_ADDRESS"), destUSDCSupply);
    }

    function _run(bool broadcast, address _srcUSDCBridgeProxy, address _circle, uint256 _destUSDCSupply) public {
        if (broadcast) vm.startBroadcast();
        SourceOFTAdapter srcUSDCBridge = SourceOFTAdapter(_srcUSDCBridgeProxy);
        srcUSDCBridge.setDestUSDCSupplySetter(srcUSDCBridge.owner());
        srcUSDCBridge.setDestUSDCSupply(_destUSDCSupply);
        srcUSDCBridge.setCircle(_circle);
        console.log("Set Circle address %s to Source USDC Bridge at %s.", _circle, address(srcUSDCBridge));
        if (broadcast) vm.stopBroadcast();
    }
}