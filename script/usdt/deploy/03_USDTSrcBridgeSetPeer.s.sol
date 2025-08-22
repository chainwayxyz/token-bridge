// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfigSetup} from "../../ConfigSetup.s.sol";
import {SourceOFTAdapter} from "../../../src/SourceOFTAdapter.sol";
import "forge-std/console.sol";

contract USDTSrcBridgeSetPeer is ConfigSetup {
    function setUp() public virtual {
        loadUSDTConfig({isUSDTDeployed: true, isBridgeDeployed: true});
    }

    // Should be called by deployer (or `src.usdt.bridge.init.owner` if role transfer is already done)
    function run() public {
        vm.createSelectFork(srcRPC);
        _run(true, srcUSDTBridgeProxy, destUSDTBridgeProxy, destEID);
    }

    function _run(bool broadcast, address _srcUSDTBridgeProxy, address _destUSDTBridgeProxy, uint32 _destEID) public {
        if (broadcast) vm.startBroadcast();
        SourceOFTAdapter(address(_srcUSDTBridgeProxy)).setPeer(_destEID, _addressToPeer(address(_destUSDTBridgeProxy)));
        if (broadcast) vm.stopBroadcast();
    }

    function _addressToPeer(address addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(addr)));
    }
}