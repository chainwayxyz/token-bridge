// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfigSetup} from "../ConfigSetup.s.sol";
import "forge-std/console.sol";
import {DestinationOUSDC} from "../../src/DestinationOUSDC.sol";

contract USDCDestBridgeSetPeer is ConfigSetup {
    function setUp() public virtual {
        loadUSDCConfig({isBridgeDeployed: true});
    }

    // Should be called by `citrea.usdc.bridge.init.owner` address
    function run() public {
        vm.createSelectFork(citreaRPC);
        _run(true, ethUSDCBridgeProxy, citreaUSDCBridgeProxy, ethEID);
    }

    function _run(bool broadcast, address _ethUSDCBridgeProxy, address _citreaUSDCBridgeProxy, uint32 _ethEID) public {
        if (broadcast) vm.startBroadcast();
        DestinationOUSDC(_citreaUSDCBridgeProxy).setPeer(_ethEID, _addressToPeer(_ethUSDCBridgeProxy));
        if (broadcast) vm.stopBroadcast();
    }

    function _addressToPeer(address addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(addr)));
    }
}