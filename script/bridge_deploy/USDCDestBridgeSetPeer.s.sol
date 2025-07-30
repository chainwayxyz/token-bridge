// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfigSetup} from "../ConfigSetup.s.sol";
import "forge-std/console.sol";
import {DestinationOUSDC} from "../../src/DestinationOUSDC.sol";

contract USDCDestBridgeSetPeer is ConfigSetup {
    function setUp() public {
        loadUSDCConfig({isBridgeDeployed: true});
    }

    // Should be called by `citrea.usdc.bridge.init.owner` address
    function run() public {
        vm.createSelectFork(citreaRPC);
        vm.startBroadcast();

        DestinationOUSDC(address(citreaUSDCBridgeProxy)).setPeer(ethEID, _addressToPeer(address(ethUSDCBridgeProxy)));

        vm.stopBroadcast();
    }

    function _addressToPeer(address addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(addr)));
    }
}