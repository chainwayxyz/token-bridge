// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {WBTCBridgeDeployTestBase} from "./base/WBTCBridgeDeployBase.t.sol";
import {WBTCDestBridgeSetPeer} from "../../../script/wbtc/deploy/05_WBTCDestBridgeSetPeer.s.sol";
import {WBTCOFT} from "../../../src/wbtc/WBTCOFT.sol";

contract WBTCDestBridgeSetPeerTest is WBTCBridgeDeployTestBase, WBTCDestBridgeSetPeer {
    function setUp() public override (WBTCBridgeDeployTestBase, WBTCDestBridgeSetPeer) {
        WBTCBridgeDeployTestBase.setUp();
    }

    function testSetPeer() public {
        vm.selectFork(destForkId);
        vm.startPrank(deployer);
        _run(false, address(destWBTCBridge_), address(srcWBTCBridge_), SRC_EID);
        bytes32 expectedPeer = bytes32(uint256(uint160(address(srcWBTCBridge_))));
        assertTrue(destWBTCBridge_.isPeer(SRC_EID, expectedPeer), "Peer should be set correctly");
    }
}
