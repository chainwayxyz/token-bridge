// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfigSetup, FiatTokenV2_2} from "../../ConfigSetup.s.sol";
import "forge-std/console.sol";
import {DestinationOUSDC} from "../../../src/DestinationOUSDC.sol";

contract USDCDestBridgeSetPeer is ConfigSetup {
    function setUp() public virtual {
        loadUSDCConfig({isBridgeDeployed: true});
    }

    // Should be called by deployer (or `dest.usdc.bridge.init.owner` if role transfer is already done)
    function run() public {
        vm.createSelectFork(destRPC);
        _run(true, destUSDC, srcUSDCBridgeProxy, destUSDCBridgeProxy, srcEID);
    }

    function _run(bool broadcast, address _destUSDC, address _srcUSDCBridgeProxy, address _destUSDCBridgeProxy, uint32 _srcEID) public {
        if (broadcast) vm.startBroadcast();
        require(FiatTokenV2_2(_destUSDC).isMinter(_destUSDCBridgeProxy), "Destination bridge is not minter");
        DestinationOUSDC(_destUSDCBridgeProxy).setPeer(_srcEID, _addressToPeer(_srcUSDCBridgeProxy));
        if (broadcast) vm.stopBroadcast();
    }

    function _addressToPeer(address addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(addr)));
    }
}