// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfigSetup} from "../../ConfigSetup.s.sol";
import {SourceOFTAdapter} from "../../../src/SourceOFTAdapter.sol";
import "forge-std/console.sol";

contract USDCSrcBridgeSetPeer is ConfigSetup {
    function setUp() public virtual {
        loadUSDCConfig({isBridgeDeployed: true});
    }

    // Should be called by `src.usdc.bridge.init.owner` address
    function run() public {
        vm.createSelectFork(srcRPC);
        _run(true, srcUSDCBridgeProxy, destUSDCBridgeProxy, destEID);
    }

    function _run(bool broadcast, address _srcUSDCBridgeProxy, address _destUSDCBridgeProxy, uint32 _destEID) public {
        if (broadcast) vm.startBroadcast();
        SourceOFTAdapter(_srcUSDCBridgeProxy).setPeer(_destEID, _addressToPeer(_destUSDCBridgeProxy));
        if (broadcast) vm.stopBroadcast();
    }

    function _addressToPeer(address addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(addr)));
    }
}