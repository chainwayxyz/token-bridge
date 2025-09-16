// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {USDCBridgeDeployTestBase} from "./base/USDCBridgeDeployBase.t.sol";
import {USDCAndBridgeAssignRoles} from "../../../script/usdc/deploy/09_USDCAndBridgeAssignRoles.s.sol";
import {DestinationOUSDC} from "../../../src/DestinationOUSDC.sol";
import {SourceOFTAdapter} from "../../../src/SourceOFTAdapter.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

interface IEndpointV2 {
    function delegates(address) external view returns (address);
}

contract USDCAndBridgeAssignRolesTest is USDCBridgeDeployTestBase, USDCAndBridgeAssignRoles {
    function setUp() public override (USDCBridgeDeployTestBase, USDCAndBridgeAssignRoles) {
        USDCBridgeDeployTestBase.setUp();
    }

    function testAssignRoles() public {
        vm.selectFork(srcForkId);
        vm.startPrank(deployer);
        address newSrcUSDCBridgeOwner = makeAddr("newSrcUSDCBridgeOwner");
        _runSrc(false, address(srcUSDCBridge), newSrcUSDCBridgeOwner);
        vm.stopPrank();
        assertEq(SourceOFTAdapter(srcUSDCBridge).owner(), newSrcUSDCBridgeOwner, "Source USDC Bridge Owner should be set");
        assertEq(IEndpointV2(address(SourceOFTAdapter(srcUSDCBridge).endpoint())).delegates(address(srcUSDCBridge)), newSrcUSDCBridgeOwner, "Source USDC Bridge Delegate should be set");

        vm.selectFork(destForkId);
        vm.startPrank(deployer);
        address newDestMMOwner = makeAddr("newDestMMOwner");
        address newDestUSDCBridgeOwner = makeAddr("newDestUSDCBridgeOwner");
        _runDest(false, address(DEST_MM), address(destUSDCBridge), newDestMMOwner, newDestUSDCBridgeOwner);
        vm.stopPrank();
        assertEq(destUSDCBridge.owner(), newDestUSDCBridgeOwner, "Destination USDC Bridge Owner should be set");
        assertEq(IEndpointV2(address(DestinationOUSDC(destUSDCBridge).endpoint())).delegates(address(destUSDCBridge)), newDestUSDCBridgeOwner, "Destination USDC Bridge Delegate should be set");
        assertEq(Ownable(DEST_MM).owner(), newDestMMOwner, "Destination MasterMinter Owner should be set");
    }
}