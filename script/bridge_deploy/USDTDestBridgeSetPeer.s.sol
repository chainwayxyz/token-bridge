// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfigSetup} from "../ConfigSetup.s.sol";
import "forge-std/console.sol";
import {DestinationOUSDT} from "../../src/DestinationOUSDT.sol";

contract USDTDestBridgeSetPeer is ConfigSetup {
    function setUp() public {
        loadUSDTConfig({isUSDTDeployed: true, isBridgeDeployed: true});
    }

    // Should be called by `citrea.usdt.bridge.init.owner` address
    function run() public {
        vm.createSelectFork(citreaRPC);
        _run(true);
    }

    function _run(bool broadcast) public {
        if (broadcast) vm.startBroadcast();
        DestinationOUSDT(address(citreaUSDTBridgeProxy)).setPeer(ethEID, _addressToPeer(address(ethUSDTBridgeProxy)));
        if (broadcast) vm.stopBroadcast();
    }

    function _addressToPeer(address addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(addr)));
    }
}