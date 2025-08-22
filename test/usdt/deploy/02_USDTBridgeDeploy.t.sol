// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {USDTBridgeDeployTestBase} from "./base/USDTBridgeDeployBase.t.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract USDTBridgeDeployTest is USDTBridgeDeployTestBase {
    function testBridgeOwner() public {
        vm.selectFork(srcForkId);
        assertEq(srcUSDTBridge.owner(), deployer, "Owner should be set to deployer initially");

        vm.selectFork(destForkId);
        assertEq(destUSDTBridge.owner(), deployer, "Owner should be set to deployer initially");
    }

    function testCannotReinitialize() public {
        vm.selectFork(srcForkId);
        vm.expectRevert(Initializable.InvalidInitialization.selector);
        srcUSDTBridge.initialize(makeAddr("arbitrary"));

        vm.selectFork(destForkId);
        vm.expectRevert(Initializable.InvalidInitialization.selector);
        destUSDTBridge.initialize(makeAddr("arbitrary"));
    }
}