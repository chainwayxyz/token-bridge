// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfigSetup} from "../../ConfigSetup.s.sol";
import {ILayerZeroEndpointV2} from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";
import "forge-std/console.sol";

contract USDCDestBridgeSetBlockedMsgLib is ConfigSetup {
    function setUp() public virtual {
        loadUSDCConfig({isBridgeDeployed: true});
    }

    // Should be called by `dest.usdc.bridge.deployment.init.owner` address
    function run() public virtual {
        vm.createSelectFork(destRPC);
        address destLzBlockedMsgLib = vm.envAddress("DEST_LZ_BLOCKED_MSG_LIB");
        _run(true, destLzEndpoint, destUSDCBridgeProxy, srcEID, destLzBlockedMsgLib);
    }

    function _run(bool broadcast, address _destLzEndpoint, address _destUSDCBridgeProxy, uint32 _srcEID, address _destLzBlockedMsgLib) public {
        if (broadcast) vm.startBroadcast();
        ILayerZeroEndpointV2(_destLzEndpoint).setSendLibrary(_destUSDCBridgeProxy, _srcEID, _destLzBlockedMsgLib);
        console.log("Set `BlockedMsgLib` %s as send library of Destination USDC Bridge at %s.", _destLzBlockedMsgLib, _destUSDCBridgeProxy);
        if (broadcast) vm.stopBroadcast();
    }
}
