// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfigSetup} from "../../ConfigSetup.s.sol";
import "forge-std/console.sol";
import {DestinationOUSDT} from "../../../src/DestinationOUSDT.sol";
import {TetherTokenOFTExtension} from "../../../src/interfaces/IOFTExtension.sol";

contract USDTDestBridgeSetPeer is ConfigSetup {
    function setUp() public virtual {
        loadUSDTConfig({isUSDTDeployed: true, isBridgeDeployed: true});
    }

    // Should be called by deployer (or `dest.usdt.bridge.init.owner` if role transfer is already done)
    function run() public {
        vm.createSelectFork(destRPC);
        _run(true, destUSDT, srcUSDTBridgeProxy, destUSDTBridgeProxy, srcEID);
    }

    function _run(bool broadcast, address _destUSDT, address _srcUSDTBridgeProxy, address _destUSDTBridgeProxy, uint32 _srcEID) public {
        if (broadcast) vm.startBroadcast();
        require(TetherTokenOFTExtension(_destUSDT).oftContract() == _destUSDTBridgeProxy, "Destination bridge is not minter");
        DestinationOUSDT(address(_destUSDTBridgeProxy)).setPeer(_srcEID, _addressToPeer(address(_srcUSDTBridgeProxy)));
        if (broadcast) vm.stopBroadcast();
    }

    function _addressToPeer(address addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(addr)));
    }
}