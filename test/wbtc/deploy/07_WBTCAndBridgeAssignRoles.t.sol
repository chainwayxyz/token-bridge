// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {WBTCBridgeDeployTestBase} from "./base/WBTCBridgeDeployBase.t.sol";
import {WBTCAndBridgeAssignRoles} from "../../../script/wbtc/deploy/07_WBTCAndBridgeAssignRoles.s.sol";
import {WBTCOFT} from "../../../src/wbtc/WBTCOFT.sol";
import {WBTCOFTAdapter} from "../../../src/wbtc/WBTCOFTAdapter.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

interface IEndpointV2 {
    function delegates(address) external view returns (address);
}

contract WBTCAndBridgeAssignRolesTest is WBTCBridgeDeployTestBase, WBTCAndBridgeAssignRoles {
    function setUp() public override (WBTCBridgeDeployTestBase, WBTCAndBridgeAssignRoles) {
        WBTCBridgeDeployTestBase.setUp();
    }

    function testAssignRoles() public {
        vm.selectFork(srcForkId);
        vm.startPrank(deployer);
        address newSrcWBTCBridgeOwner = makeAddr("newSrcWBTCBridgeOwner");
        _runSrc(false, address(srcWBTCBridge_), newSrcWBTCBridgeOwner);
        vm.stopPrank();
        assertEq(WBTCOFTAdapter(srcWBTCBridge_).owner(), newSrcWBTCBridgeOwner, "Source WBTC Bridge Owner should be set");
        assertEq(IEndpointV2(address(WBTCOFTAdapter(srcWBTCBridge_).endpoint())).delegates(address(srcWBTCBridge_)), newSrcWBTCBridgeOwner, "Source WBTC Bridge Delegate should be set");

        vm.selectFork(destForkId);
        vm.startPrank(deployer);
        address newDestWBTCBridgeOwner = makeAddr("newDestWBTCBridgeOwner");
        _runDest(false, address(destWBTCBridge_), newDestWBTCBridgeOwner);
        vm.stopPrank();
        assertEq(destWBTCBridge_.owner(), newDestWBTCBridgeOwner, "Destination WBTC Bridge Owner should be set");
        assertEq(IEndpointV2(address(WBTCOFT(destWBTCBridge_).endpoint())).delegates(address(destWBTCBridge_)), newDestWBTCBridgeOwner, "Destination WBTC Bridge Delegate should be set");
        assertEq(destWBTCBridge_.feeOwner(), newDestWBTCBridgeOwner, "Destination WBTC Bridge Fee Owner should be set");
    }
}
