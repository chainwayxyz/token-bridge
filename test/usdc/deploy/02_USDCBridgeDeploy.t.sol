// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "./base/USDCBridgeDeployBase.t.sol";

contract USDCBridgeDeployTest is USDCBridgeDeployTestBase {
    function setUp() public virtual override {
        super.setUp();
    }

    function testBridgeOwner() public {
        vm.selectFork(srcForkId);
        assertEq(srcUSDCBridge.owner(), deployer, "Owner should be set correctly");

        vm.selectFork(destForkId);
        assertEq(destUSDCBridge.owner(), deployer, "Owner should be set correctly");
    }

    function testCannotReinitialize() public {
        vm.selectFork(srcForkId);
        vm.expectRevert(Initializable.InvalidInitialization.selector);
        srcUSDCBridge.initialize(makeAddr("arbitrary"));

        vm.selectFork(destForkId);
        vm.expectRevert(Initializable.InvalidInitialization.selector);
        destUSDCBridge.initialize(makeAddr("arbitrary"));
    }
}