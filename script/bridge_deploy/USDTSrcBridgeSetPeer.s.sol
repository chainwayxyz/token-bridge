// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfigSetup} from "../ConfigSetup.s.sol";
import {SourceOFTAdapter} from "../../src/SourceOFTAdapter.sol";
import "forge-std/console.sol";

contract USDTSrcBridgeSetPeer is ConfigSetup {
    function setUp() public {
        loadUSDTConfig({isUSDTDeployed: true, isBridgeDeployed: true});
    }

    // Should be called by `eth.usdt.bridge.init.owner` address
    function run() public {
        vm.createSelectFork(ethRPC);
        vm.startBroadcast();

        SourceOFTAdapter(address(ethUSDTBridgeProxy)).setPeer(citreaEID, _addressToPeer(address(citreaUSDTBridgeProxy)));

        vm.stopBroadcast();
    }

    function _addressToPeer(address addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(addr)));
    }
}