// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {USDCBridgeDeployTest} from "./USDCBridgeDeploy.t.sol";
import {USDCDestBridgeSetPeer} from "../../script/bridge_deploy/USDCDestBridgeSetPeer.s.sol";
import {DestinationOUSDC} from "../../src/DestinationOUSDC.sol";

contract USDCDestBridgeSetPeerTest is USDCBridgeDeployTest, USDCDestBridgeSetPeer {
    USDCDestBridgeSetPeer public usdcDestBridgeSetPeer;

    function setUp() public override (USDCBridgeDeployTest, USDCDestBridgeSetPeer) {
        USDCBridgeDeployTest.setUp();
        USDCDestBridgeSetPeer.setUp();
    }

    function testSetPeer() public {
        vm.selectFork(citreaForkId);
        vm.startPrank(citreaUSDCBridgeOwner);
        _run(false);
        // Verify that the peer address is set correctly
        bytes32 expectedPeer = _addressToPeer(address(ethUSDCBridgeProxy));
        assertTrue(DestinationOUSDC(citreaUSDCBridgeProxy).isPeer(ethEID, expectedPeer), "Peer should be set correctly");
    }
}