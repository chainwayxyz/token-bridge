// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {WBTCBridgeDeployTestBase} from "./base/WBTCBridgeDeployBase.t.sol";
import {WBTCOFTAdapter} from "../../../src/wbtc/WBTCOFTAdapter.sol";

contract WBTCSrcBridgeDeployTest is WBTCBridgeDeployTestBase {
    function testBridgeOwner() public {
        vm.selectFork(srcForkId);
        assertEq(srcWBTCBridge_.owner(), deployer, "Owner should be set to deployer initially");
    }

    function testTokenAddress() public {
        vm.selectFork(srcForkId);
        assertEq(srcWBTCBridge_.token(), SRC_WBTC, "Token address should match source WBTC");
    }
}
