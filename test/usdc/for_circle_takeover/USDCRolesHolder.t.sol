// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./base/USDCTransferOwnerBase.t.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import {USDCRolesHolder} from "../../../src/USDCRolesHolder.sol";

contract USDCRolesHolderTest is USDCTransferOwnerTestBase {
    function setUp() public override (USDCTransferOwnerTestBase) {
        USDCTransferOwnerTestBase.setUp();
    }

    function testTransferOwnership() public {
        vm.selectFork(destForkId);
        vm.startPrank(USDCRolesHolder(usdcRolesHolder).owner());
        address newOwner = makeAddr("NEW_OWNER");
        USDCRolesHolder(usdcRolesHolder).transferOwnership(newOwner);
        vm.stopPrank();
        vm.startPrank(newOwner);
        USDCRolesHolder(usdcRolesHolder).acceptOwnership();
        assertEq(USDCRolesHolder(usdcRolesHolder).owner(), newOwner, "Ownership should be transferred to the new owner");
    }

    function testOnlyPendingOwnerCanAcceptOwnership() public {
        vm.selectFork(destForkId);
        vm.startPrank(USDCRolesHolder(usdcRolesHolder).owner());
        address newOwner = makeAddr("NEW_OWNER");
        USDCRolesHolder(usdcRolesHolder).transferOwnership(newOwner);
        vm.stopPrank();
        address notPendingOwner = makeAddr("NOT_PENDING_OWNER");
        vm.startPrank(notPendingOwner);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, notPendingOwner));
        USDCRolesHolder(usdcRolesHolder).acceptOwnership();
    }
}