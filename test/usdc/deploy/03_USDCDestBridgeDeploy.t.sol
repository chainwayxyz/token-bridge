// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "./base/USDCBridgeDeployBase.t.sol";

contract USDCDestBridgeDeployTest is USDCBridgeDeployTestBase {
    function setUp() public virtual override {
        super.setUp();
    }

    function testBridgeOwner() public {
        vm.selectFork(destForkId);
        assertEq(destUSDCBridge.owner(), deployer, "Owner should be set correctly");
    }

    function testCannotReinitialize() public {
        vm.selectFork(destForkId);
        vm.expectRevert(Initializable.InvalidInitialization.selector);
        destUSDCBridge.initialize(makeAddr("arbitrary"));
    }
}