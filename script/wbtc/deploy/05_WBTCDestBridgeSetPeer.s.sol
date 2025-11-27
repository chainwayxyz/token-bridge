// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfigSetup} from "../../ConfigSetup.s.sol";
import {WBTCOFT} from "../../../src/wbtc/WBTCOFT.sol";
import "forge-std/console.sol";

contract WBTCDestBridgeSetPeer is ConfigSetup {
    function setUp() public virtual {
        loadWBTCConfig({isBridgeDeployed: true});
    }

    // Should be called by deployer (or `dest.wbtc.bridge.init.owner` if role transfer is already done)
    function run() public {
        vm.createSelectFork(destRPC);
        _run(true, destWBTCBridge, srcWBTCBridge, srcEID);
    }

    function _run(bool broadcast, address _destWBTCBridge, address _srcWBTCBridge, uint32 _srcEID) public {
        if (broadcast) vm.startBroadcast();
        WBTCOFT(_destWBTCBridge).setPeer(_srcEID, _addressToPeer(_srcWBTCBridge));
        if (broadcast) vm.stopBroadcast();
    }

    function _addressToPeer(address addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(addr)));
    }
}
