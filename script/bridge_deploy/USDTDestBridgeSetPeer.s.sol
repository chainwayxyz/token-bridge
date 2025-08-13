// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfigSetup} from "../ConfigSetup.s.sol";
import "forge-std/console.sol";
import {DestinationOUSDT} from "../../src/DestinationOUSDT.sol";

contract USDTDestBridgeSetPeer is ConfigSetup {
    function setUp() public virtual {
        loadUSDTConfig({isUSDTDeployed: true, isBridgeDeployed: true});
    }

    // Should be called by `dest.usdt.bridge.init.owner` address
    function run() public {
        vm.createSelectFork(destRPC);
        _run(true, srcUSDTBridgeProxy, destUSDTBridgeProxy, srcEID);
    }

    function _run(bool broadcast, address _srcUSDTBridgeProxy, address _destUSDTBridgeProxy, uint32 _srcEID) public {
        if (broadcast) vm.startBroadcast();
        DestinationOUSDT(address(_destUSDTBridgeProxy)).setPeer(_srcEID, _addressToPeer(address(_srcUSDTBridgeProxy)));
        if (broadcast) vm.stopBroadcast();
    }

    function _addressToPeer(address addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(addr)));
    }
}