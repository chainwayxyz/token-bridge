// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {USDCBridgeDeployTestBase} from "./base/USDCBridgeDeployBase.t.sol";
import {USDCDestBridgeSetPeer} from "../../script/bridge_deploy/USDCDestBridgeSetPeer.s.sol";
import {DestinationOUSDC} from "../../src/DestinationOUSDC.sol";

contract USDCDestBridgeSetPeerTest is USDCBridgeDeployTestBase, USDCDestBridgeSetPeer {
    function setUp() public override (USDCBridgeDeployTestBase, USDCDestBridgeSetPeer) {
        USDCBridgeDeployTestBase.setUp();
    }

    function testSetPeer() public {
        vm.selectFork(citreaForkId);
        vm.startPrank(citreaUSDCBridge.owner());
        _run(false, address(ethUSDCBridge), address(citreaUSDCBridge), ETH_EID);
        bytes32 expectedPeer = _addressToPeer(address(ethUSDCBridge));
        assertTrue(citreaUSDCBridge.isPeer(ETH_EID, expectedPeer), "Peer should be set correctly");
    }
}