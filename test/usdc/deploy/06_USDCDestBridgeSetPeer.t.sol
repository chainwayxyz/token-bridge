// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {USDCBridgeDeployTestBase} from "./base/USDCBridgeDeployBase.t.sol";
import {USDCDestBridgeSetPeer} from "../../../script/usdc/deploy/06_USDCDestBridgeSetPeer.s.sol";
import {DestinationOUSDC} from "../../../src/DestinationOUSDC.sol";
import {MasterMinter} from "../../../src/interfaces/IMasterMinter.sol";

contract USDCDestBridgeSetPeerTest is USDCBridgeDeployTestBase, USDCDestBridgeSetPeer {
    function setUp() public override (USDCBridgeDeployTestBase, USDCDestBridgeSetPeer) {
        USDCBridgeDeployTestBase.setUp();
    }

    function testSetPeer() public {
        vm.selectFork(destForkId);
        vm.startPrank(deployer);
        MasterMinter(DEST_MM).configureController(deployer, address(destUSDCBridge));
        MasterMinter(DEST_MM).configureMinter(type(uint256).max);
        _run(false, DEST_USDC, address(srcUSDCBridge), address(destUSDCBridge), SRC_EID);
        bytes32 expectedPeer = _addressToPeer(address(srcUSDCBridge));
        assertTrue(destUSDCBridge.isPeer(SRC_EID, expectedPeer), "Peer should be set correctly");
    }
}