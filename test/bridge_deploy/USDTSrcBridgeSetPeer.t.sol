// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {USDTBridgeDeployTestBase} from "./base/USDTBridgeDeployBase.t.sol";
import {USDTSrcBridgeSetPeer} from "../../script/bridge_deploy/USDTSrcBridgeSetPeer.s.sol";
import {SourceOFTAdapter} from "../../src/SourceOFTAdapter.sol";

contract USDTSrcBridgeSetPeerTest is USDTBridgeDeployTestBase, USDTSrcBridgeSetPeer {
    function setUp() public override (USDTBridgeDeployTestBase, USDTSrcBridgeSetPeer) {
        USDTBridgeDeployTestBase.setUp();
    }

    function testSetPeer() public {
        vm.selectFork(ethForkId);
        vm.startPrank(ethUSDTBridge.owner());
        _run(false, address(ethUSDTBridge), address(citreaUSDTBridge), CITREA_EID);
        bytes32 expectedPeer = _addressToPeer(address(citreaUSDTBridge));
        assertTrue(ethUSDTBridge.isPeer(CITREA_EID, expectedPeer), "Peer should be set correctly");
    }
}