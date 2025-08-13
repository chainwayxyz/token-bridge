// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {USDTBridgeDeployTestBase} from "./base/USDTBridgeDeployBase.t.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract USDTBridgeDeployTest is USDTBridgeDeployTestBase {
    function testBridgeOwner() public {
        vm.selectFork(ethForkId);
        assertEq(ethUSDTBridge.owner(), mockEthUSDTBridgeOwner, "Owner should be set correctly");

        vm.selectFork(citreaForkId);
        assertEq(citreaUSDTBridge.owner(), mockCitreaUSDTBridgeOwner, "Owner should be set correctly");
    }

    function testCannotReinitialize() public {
        vm.selectFork(ethForkId);
        vm.expectRevert(Initializable.InvalidInitialization.selector);
        ethUSDTBridge.initialize(makeAddr("arbitrary"));

        vm.selectFork(citreaForkId);
        vm.expectRevert(Initializable.InvalidInitialization.selector);
        citreaUSDTBridge.initialize(makeAddr("arbitrary"));
    }
}