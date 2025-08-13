// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {USDCBridgeDeployTestBase} from "./base/USDCBridgeDeployBase.t.sol";
import {USDCSrcBridgeSetPeer} from "../../script/bridge_deploy/USDCSrcBridgeSetPeer.s.sol";
import {SourceOFTAdapter} from "../../src/SourceOFTAdapter.sol";

contract USDCSrcBridgeSetPeerTest is USDCBridgeDeployTestBase, USDCSrcBridgeSetPeer {
    function setUp() public override (USDCBridgeDeployTestBase, USDCSrcBridgeSetPeer) {
        USDCBridgeDeployTestBase.setUp();
    }

    function testSetPeer() public {
        vm.selectFork(ethForkId);
        vm.startPrank(ethUSDCBridge.owner());
        _run(false, address(ethUSDCBridge), address(citreaUSDCBridge), CITREA_EID);
        bytes32 expectedPeer = _addressToPeer(address(citreaUSDCBridge));
        assertTrue(ethUSDCBridge.isPeer(CITREA_EID, expectedPeer), "Peer should be set correctly");
    }
}