// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./base/USDCTransferOwnerBase.t.sol";

contract USDCTransferOwnerTest is USDCTransferOwnerTestBase {
    function testUSDCOwnerTransfer() public view {
        assertEq(FiatTokenV2_2(CITREA_USDC).owner(), usdcRolesHolder, "USDC owner should be transferred to the new address");
    }
}