// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {USDTBridgeDeployTestBase} from "./base/USDTBridgeDeployBase.t.sol";
import {USDTAndBridgeAssignRoles} from "../../../script/usdt/deploy/06_USDTAndBridgeAssignRoles.s.sol";
import {DestinationOUSDT} from "../../../src/DestinationOUSDT.sol";
import {SourceOFTAdapter} from "../../../src/SourceOFTAdapter.sol";

interface IEndpointV2 {
    function delegates(address) external view returns (address);
}

contract USDTAndBridgeAssignRolesTest is USDTBridgeDeployTestBase, USDTAndBridgeAssignRoles {
    function setUp() public override (USDTBridgeDeployTestBase, USDTAndBridgeAssignRoles) {
        USDTBridgeDeployTestBase.setUp();
    }

    function testAssignRoles() public {
        vm.selectFork(srcForkId);
        vm.startPrank(deployer);
        address newSrcUSDTBridgeOwner = makeAddr("newSrcUSDTBridgeOwner");
        _runSrc(false, address(srcUSDTBridge), newSrcUSDTBridgeOwner);
        vm.stopPrank();
        assertEq(SourceOFTAdapter(srcUSDTBridge).owner(), newSrcUSDTBridgeOwner, "Source USDT Bridge Owner should be set");
        assertEq(IEndpointV2(address(SourceOFTAdapter(srcUSDTBridge).endpoint())).delegates(address(srcUSDTBridge)), newSrcUSDTBridgeOwner, "Source USDT Bridge Delegate should be set");

        vm.selectFork(destForkId);
        vm.startPrank(deployer);
        address newDestUSDTBridgeOwner = makeAddr("newDestUSDTBridgeOwner");
        address newDestUSDTOwner = makeAddr("newDestUSDTOwner");
        _runDest(false, address(usdt), address(destUSDTBridge), newDestUSDTOwner, newDestUSDTBridgeOwner);
        vm.stopPrank();
        assertEq(destUSDTBridge.owner(), newDestUSDTBridgeOwner, "Destination USDT Bridge Owner should be set");
        assertEq(IEndpointV2(address(DestinationOUSDT(destUSDTBridge).endpoint())).delegates(address(destUSDTBridge)), newDestUSDTBridgeOwner, "Destination USDT Bridge Delegate should be set");
        assertEq(usdt.owner(), newDestUSDTOwner, "Destination USDT Owner should be set");
    }
}