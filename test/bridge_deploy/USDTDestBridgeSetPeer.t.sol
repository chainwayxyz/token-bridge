// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {USDTBridgeDeployTestBase} from "./base/USDTBridgeDeployBase.t.sol";
import {USDTDestBridgeSetPeer} from "../../script/bridge_deploy/USDTDestBridgeSetPeer.s.sol";
import {SourceOFTAdapter} from "../../src/SourceOFTAdapter.sol";

contract USDTDestBridgeSetPeerTest is USDTBridgeDeployTestBase, USDTDestBridgeSetPeer {
    function setUp() public override (USDTBridgeDeployTestBase, USDTDestBridgeSetPeer) {
        USDTBridgeDeployTestBase.setUp();
    }

    function testSetPeer() public {
        vm.selectFork(citreaForkId);
        vm.startPrank(citreaUSDTBridge.owner());
        _run(false, address(ethUSDTBridge), address(citreaUSDTBridge), ETH_EID);
        bytes32 expectedPeer = _addressToPeer(address(ethUSDTBridge));
        assertTrue(citreaUSDTBridge.isPeer(ETH_EID, expectedPeer), "Peer should be set correctly");
    }
}