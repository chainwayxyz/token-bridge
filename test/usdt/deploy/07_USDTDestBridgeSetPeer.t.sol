// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {USDTBridgeDeployTestBase} from "./base/USDTBridgeDeployBase.t.sol";
import {USDTDestBridgeSetPeer} from "../../../script/usdt/deploy/07_USDTDestBridgeSetPeer.s.sol";
import {SourceOFTAdapter} from "../../../src/SourceOFTAdapter.sol";

contract USDTDestBridgeSetPeerTest is USDTBridgeDeployTestBase, USDTDestBridgeSetPeer {
    function setUp() public override (USDTBridgeDeployTestBase, USDTDestBridgeSetPeer) {
        USDTBridgeDeployTestBase.setUp();
    }

    function testSetPeer() public {
        vm.selectFork(destForkId);
        vm.startPrank(deployer);
        usdt.setOFTContract(address(destUSDTBridge));
        _run(false, address(usdt), address(srcUSDTBridge), address(destUSDTBridge), SRC_EID);
        bytes32 expectedPeer = _addressToPeer(address(srcUSDTBridge));
        assertTrue(destUSDTBridge.isPeer(SRC_EID, expectedPeer), "Peer should be set correctly");
    }
}