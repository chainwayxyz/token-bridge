// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {USDTBridgeDeployTestBase} from "./base/USDTBridgeDeployBase.t.sol";
import {USDTSrcBridgeSetPeer} from "../../../script/usdt/deploy/08_USDTSrcBridgeSetPeer.s.sol";
import {SourceOFTAdapter} from "../../../src/SourceOFTAdapter.sol";

contract USDTSrcBridgeSetPeerTest is USDTBridgeDeployTestBase, USDTSrcBridgeSetPeer {
    function setUp() public override (USDTBridgeDeployTestBase, USDTSrcBridgeSetPeer) {
        USDTBridgeDeployTestBase.setUp();
    }

    function testSetPeer() public {
        vm.selectFork(srcForkId);
        vm.startPrank(deployer);
        _run(false, address(srcUSDTBridge), address(destUSDTBridge), DEST_EID);
        bytes32 expectedPeer = _addressToPeer(address(destUSDTBridge));
        assertTrue(srcUSDTBridge.isPeer(DEST_EID, expectedPeer), "Peer should be set correctly");
    }
}