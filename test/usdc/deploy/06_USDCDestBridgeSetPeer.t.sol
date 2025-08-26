// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {USDCBridgeDeployTestBase} from "./base/USDCBridgeDeployBase.t.sol";
import {USDCDestBridgeSetPeer} from "../../../script/usdc/deploy/06_USDCDestBridgeSetPeer.s.sol";
import {DestinationOUSDC} from "../../../src/DestinationOUSDC.sol";

contract USDCDestBridgeSetPeerTest is USDCBridgeDeployTestBase, USDCDestBridgeSetPeer {
    function setUp() public override (USDCBridgeDeployTestBase, USDCDestBridgeSetPeer) {
        USDCBridgeDeployTestBase.setUp();
    }

    function testSetPeer() public {
        vm.selectFork(destForkId);
        vm.startPrank(deployer);
        _run(false, address(srcUSDCBridge), address(destUSDCBridge), SRC_EID);
        bytes32 expectedPeer = _addressToPeer(address(srcUSDCBridge));
        assertTrue(destUSDCBridge.isPeer(SRC_EID, expectedPeer), "Peer should be set correctly");
    }
}