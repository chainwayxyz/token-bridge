// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfigSetup} from "../../ConfigSetup.s.sol";
import {ILayerZeroEndpointV2} from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";
import "forge-std/console.sol";

contract USDCSrcBridgeSetBlockedMsgLib is ConfigSetup {
    function setUp() public virtual {
        loadUSDCConfig({isBridgeDeployed: true});
    }

    // Should be called by `src.usdc.bridge.deployment.init.owner` address
    function run() public virtual {
        vm.createSelectFork(srcRPC);
        address srcLzBlockedMsgLib = vm.envAddress("SRC_LZ_BLOCKED_MSG_LIB");
        _run(true, srcLzEndpoint, srcUSDCBridgeProxy, destEID, srcLzBlockedMsgLib);
    }

    function _run(bool broadcast, address _srcLzEndpoint, address _srcUSDCBridgeProxy, uint32 _destEID, address _srcLzBlockedMsgLib) public {
        if (broadcast) vm.startBroadcast();
        ILayerZeroEndpointV2(_srcLzEndpoint).setSendLibrary(_srcUSDCBridgeProxy, _destEID, _srcLzBlockedMsgLib);
        console.log("Set `BlockedMsgLib` %s as send library of Source USDC Bridge at %s.", _srcLzBlockedMsgLib, _srcUSDCBridgeProxy);
        if (broadcast) vm.stopBroadcast();
    }
}
