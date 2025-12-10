// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfigSetup} from "../../ConfigSetup.s.sol";
import {WBTCOFTAdapter} from "../../../src/wbtc/WBTCOFTAdapter.sol";
import "forge-std/console.sol";

contract WBTCSrcBridgeSetPeer is ConfigSetup {
    function setUp() public virtual {
        loadWBTCConfig({isBridgeDeployed: true});
    }

    // Should be called by deployer (or `src.wbtc.bridge.init.owner` if role transfer is already done)
    function run() public {
        vm.createSelectFork(srcRPC);
        _run(true, srcWBTCBridge, destWBTCBridge, destEID);
    }

    function _run(bool broadcast, address _srcWBTCBridge, address _destWBTCBridge, uint32 _destEID) public {
        if (broadcast) vm.startBroadcast();
        WBTCOFTAdapter(_srcWBTCBridge).setPeer(_destEID, _addressToPeer(_destWBTCBridge));
        if (broadcast) vm.stopBroadcast();
    }

    function _addressToPeer(address addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(addr)));
    }
}
