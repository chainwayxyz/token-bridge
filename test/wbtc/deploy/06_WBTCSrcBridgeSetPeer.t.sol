// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {WBTCBridgeDeployTestBase} from "./base/WBTCBridgeDeployBase.t.sol";
import {WBTCSrcBridgeSetPeer} from "../../../script/wbtc/deploy/06_WBTCSrcBridgeSetPeer.s.sol";
import {WBTCOFTAdapter} from "../../../src/wbtc/WBTCOFTAdapter.sol";

contract WBTCSrcBridgeSetPeerTest is WBTCBridgeDeployTestBase, WBTCSrcBridgeSetPeer {
    function setUp() public override (WBTCBridgeDeployTestBase, WBTCSrcBridgeSetPeer) {
        WBTCBridgeDeployTestBase.setUp();
    }

    function testSetPeer() public {
        vm.selectFork(srcForkId);
        vm.startPrank(deployer);
        _run(false, address(srcWBTCBridge_), address(destWBTCBridge_), DEST_EID);
        bytes32 expectedPeer = bytes32(uint256(uint160(address(destWBTCBridge_))));
        assertTrue(srcWBTCBridge_.isPeer(DEST_EID, expectedPeer), "Peer should be set correctly");
    }
}
