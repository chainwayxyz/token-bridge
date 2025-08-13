// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfigSetup} from "../ConfigSetup.s.sol";
import {SourceOFTAdapter} from "../../src/SourceOFTAdapter.sol";
import "forge-std/console.sol";

contract USDCSrcBridgeSetPeer is ConfigSetup {
    function setUp() public virtual {
        loadUSDCConfig({isBridgeDeployed: true});
    }

    // Should be called by `eth.usdc.bridge.init.owner` address
    function run() public {
        vm.createSelectFork(ethRPC);
        _run(true, ethUSDCBridgeProxy, citreaUSDCBridgeProxy, citreaEID);
    }

    function _run(bool broadcast, address _ethUSDCBridgeProxy, address _citreaUSDCBridgeProxy, uint32 _citreaEID) public {
        if (broadcast) vm.startBroadcast();
        SourceOFTAdapter(_ethUSDCBridgeProxy).setPeer(_citreaEID, _addressToPeer(_citreaUSDCBridgeProxy));
        if (broadcast) vm.stopBroadcast();
    }

    function _addressToPeer(address addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(addr)));
    }
}