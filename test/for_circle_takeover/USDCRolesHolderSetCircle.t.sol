// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./base/USDCTransferOwnerBase.t.sol";
import {USDCRolesHolderSetCircle} from "../../script/for_circle_takeover/USDCRolesHolderSetCircle.s.sol";
import {USDCRolesHolder} from "../../src/USDCRolesHolder.sol";

contract USDCRolesHolderSetCircleTest is USDCTransferOwnerTestBase, USDCRolesHolderSetCircle {
    function setUp() public override (USDCTransferOwnerTestBase, USDCRolesHolderSetCircle) {
        USDCTransferOwnerTestBase.setUp();
    }

    function run() public override (USDCTransferOwner, USDCRolesHolderSetCircle) {}

    function testSetCircle() public {
        vm.selectFork(citreaForkId);
        vm.startPrank(USDCRolesHolder(usdcRolesHolder).owner());
        address circle = makeAddr("CIRCLE_ADDRESS");
        _run(false, address(CITREA_USDC), circle);
        assertEq(USDCRolesHolder(usdcRolesHolder).circle(), circle, "Circle address should be set correctly");
    }

    function testCircleCanAssumeUSDCOwnership() public {
        vm.selectFork(citreaForkId);
        vm.startPrank(USDCRolesHolder(usdcRolesHolder).owner());
        address circle = makeAddr("CIRCLE_ADDRESS");
        _run(false, address(CITREA_USDC), circle);
        vm.stopPrank();
        vm.startPrank(circle);
        address circleOwner = makeAddr("CIRCLE_OWNER");
        USDCRolesHolder(usdcRolesHolder).transferUSDCRoles(circleOwner);
        vm.stopPrank();
        assertEq(FiatTokenV2_2(CITREA_USDC).owner(), circleOwner, "USDC owner should be transferred to Circle address");
    }
}