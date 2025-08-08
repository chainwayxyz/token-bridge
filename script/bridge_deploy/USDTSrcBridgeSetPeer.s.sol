// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfigSetup} from "../ConfigSetup.s.sol";
import {SourceOFTAdapter} from "../../src/SourceOFTAdapter.sol";
import "forge-std/console.sol";

contract USDTSrcBridgeSetPeer is ConfigSetup {
    function setUp() public virtual {
        loadUSDTConfig({isUSDTDeployed: true, isBridgeDeployed: true});
    }

    // Should be called by `eth.usdt.bridge.init.owner` address
    function run() public {
        vm.createSelectFork(ethRPC);
        _run(true, ethUSDTBridgeProxy, citreaUSDTBridgeProxy, citreaEID);
    }

    function _run(bool broadcast, address _ethUSDTBridgeProxy, address _citreaUSDTBridgeProxy, uint32 _citreaEID) public {
        if (broadcast) vm.startBroadcast();
        SourceOFTAdapter(address(_ethUSDTBridgeProxy)).setPeer(_citreaEID, _addressToPeer(address(_citreaUSDTBridgeProxy)));
        if (broadcast) vm.stopBroadcast();
    }

    function _addressToPeer(address addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(addr)));
    }
}