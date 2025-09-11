// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {USDCBridgeDeployTestBase} from "./base/USDCBridgeDeployBase.t.sol";
import {USDCSrcBridgeSetPeer} from "../../../script/usdc/deploy/07_USDCSrcBridgeSetPeer.s.sol";
import {SourceOFTAdapter} from "../../../src/SourceOFTAdapter.sol";

contract USDCSrcBridgeSetPeerTest is USDCBridgeDeployTestBase, USDCSrcBridgeSetPeer {
    function setUp() public override (USDCBridgeDeployTestBase, USDCSrcBridgeSetPeer) {
        USDCBridgeDeployTestBase.setUp();
    }

    function testSetPeer() public {
        vm.selectFork(srcForkId);
        vm.startPrank(deployer);
        _run(false, address(srcUSDCBridge), address(destUSDCBridge), DEST_EID);
        bytes32 expectedPeer = _addressToPeer(address(destUSDCBridge));
        assertTrue(srcUSDCBridge.isPeer(DEST_EID, expectedPeer), "Peer should be set correctly");
    }
}