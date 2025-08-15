// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./base/USDCTransferOwnerBase.t.sol";
import {USDCRolesHolderSetCircle} from "../../../script/usdc/for_circle_takeover/09_USDCRolesHolderSetCircle.s.sol";
import {USDCRolesHolder} from "../../../src/USDCRolesHolder.sol";

contract USDCRolesHolderSetCircleTest is USDCTransferOwnerTestBase, USDCRolesHolderSetCircle {
    function setUp() public override (USDCTransferOwnerTestBase, USDCRolesHolderSetCircle) {
        USDCTransferOwnerTestBase.setUp();
    }

    function run() public override (USDCTransferOwner, USDCRolesHolderSetCircle) {}

    function testSetCircle() public {
        vm.selectFork(destForkId);
        vm.startPrank(USDCRolesHolder(usdcRolesHolder).owner());
        address circle = makeAddr("CIRCLE_ADDRESS");
        _run(false, address(DEST_USDC), circle);
        assertEq(USDCRolesHolder(usdcRolesHolder).circle(), circle, "Circle address should be set correctly");
    }

    function testCircleCanAssumeUSDCOwnership() public {
        vm.selectFork(destForkId);
        vm.startPrank(USDCRolesHolder(usdcRolesHolder).owner());
        address circle = makeAddr("CIRCLE_ADDRESS");
        _run(false, address(DEST_USDC), circle);
        vm.stopPrank();
        vm.startPrank(circle);
        address circleOwner = makeAddr("CIRCLE_OWNER");
        USDCRolesHolder(usdcRolesHolder).transferUSDCRoles(circleOwner);
        vm.stopPrank();
        assertEq(FiatTokenV2_2(DEST_USDC).owner(), circleOwner, "USDC owner should be transferred to Circle address");
    }
}