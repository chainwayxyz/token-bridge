// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "./base/USDCBridgeDeployBase.t.sol";

contract USDCBridgeDeployTest is USDCBridgeDeployTestBase {
    function setUp() public virtual override {
        super.setUp();
    }

    function testBridgeOwner() public {
        vm.selectFork(ethForkId);
        assertEq(ethUSDCBridge.owner(), mockEthUSDCBridgeOwner, "Owner should be set correctly");

        vm.selectFork(citreaForkId);
        assertEq(citreaUSDCBridge.owner(), mockCitreaUSDCBridgeOwner, "Owner should be set correctly");
    }

    function testCannotReinitialize() public {
        vm.selectFork(ethForkId);
        vm.expectRevert(Initializable.InvalidInitialization.selector);
        ethUSDCBridge.initialize(makeAddr("arbitrary"));

        vm.selectFork(citreaForkId);
        vm.expectRevert(Initializable.InvalidInitialization.selector);
        citreaUSDCBridge.initialize(makeAddr("arbitrary"));
    }
}