// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {USDCBridgeDeployTestBase} from "./base/USDCBridgeDeployBase.t.sol";
import {USDCDestBridgeSetPeer} from "../../../script/usdc/bridge_deploy/03_USDCDestBridgeSetPeer.s.sol";
import {DestinationOUSDC} from "../../../src/DestinationOUSDC.sol";

contract USDCDestBridgeSetPeerTest is USDCBridgeDeployTestBase, USDCDestBridgeSetPeer {
    function setUp() public override (USDCBridgeDeployTestBase, USDCDestBridgeSetPeer) {
        USDCBridgeDeployTestBase.setUp();
    }

    function testSetPeer() public {
        vm.selectFork(destForkId);
        vm.startPrank(destUSDCBridge.owner());
        _run(false, address(srcUSDCBridge), address(destUSDCBridge), SRC_EID);
        bytes32 expectedPeer = _addressToPeer(address(srcUSDCBridge));
        assertTrue(destUSDCBridge.isPeer(SRC_EID, expectedPeer), "Peer should be set correctly");
    }
}