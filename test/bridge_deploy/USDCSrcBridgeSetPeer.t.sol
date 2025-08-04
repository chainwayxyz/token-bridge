// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {USDCBridgeDeployTest} from "./USDCBridgeDeploy.t.sol";
import {USDCSrcBridgeSetPeer} from "../../script/bridge_deploy/USDCSrcBridgeSetPeer.s.sol";
import {SourceOFTAdapter} from "../../src/SourceOFTAdapter.sol";

contract USDCSrcBridgeSetPeerTest is USDCBridgeDeployTest, USDCSrcBridgeSetPeer {
    USDCSrcBridgeSetPeer public usdcSrcBridgeSetPeer;

    function setUp() public override (USDCBridgeDeployTest, USDCSrcBridgeSetPeer) {
        USDCBridgeDeployTest.setUp();
        USDCSrcBridgeSetPeer.setUp();
    }

    function testSetPeer() public {
        vm.selectFork(ethForkId);
        vm.startPrank(ethUSDCBridgeOwner);
        _run(false);
        // Verify that the peer address is set correctly
        bytes32 expectedPeer = _addressToPeer(address(citreaUSDCBridgeProxy));
        assertTrue(SourceOFTAdapter(ethUSDCBridgeProxy).isPeer(citreaEID, expectedPeer), "Peer should be set correctly");
    }
}