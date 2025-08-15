// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfigSetup} from "../../ConfigSetup.s.sol";
import "forge-std/console.sol";
import {DestinationOUSDC} from "../../../src/DestinationOUSDC.sol";

contract USDCDestBridgeSetPeer is ConfigSetup {
    function setUp() public virtual {
        loadUSDCConfig({isBridgeDeployed: true});
    }

    // Should be called by `dest.usdc.bridge.init.owner` address
    function run() public {
        vm.createSelectFork(destRPC);
        _run(true, srcUSDCBridgeProxy, destUSDCBridgeProxy, srcEID);
    }

    function _run(bool broadcast, address _srcUSDCBridgeProxy, address _destUSDCBridgeProxy, uint32 _srcEID) public {
        if (broadcast) vm.startBroadcast();
        DestinationOUSDC(_destUSDCBridgeProxy).setPeer(_srcEID, _addressToPeer(_srcUSDCBridgeProxy));
        if (broadcast) vm.stopBroadcast();
    }

    function _addressToPeer(address addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(addr)));
    }
}