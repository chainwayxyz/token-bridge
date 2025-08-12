// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {USDCBridgeDeployTestBase} from "../bridge_deploy/base/USDCBridgeDeployBase.t.sol";
import {DestinationOUSDCHarness, FiatTokenV2_2} from "../bridge_deploy/USDCSetBridgeAsMinter.t.sol";
import {USDCRemoveBridgeAsMinter, MasterMinter} from "../../script/for_circle_takeover/USDCRemoveBridgeAsMinter.s.sol";

contract USDCRemoveBridgeAsMinterTest is USDCBridgeDeployTestBase, USDCRemoveBridgeAsMinter {
    function setUp() public override (USDCRemoveBridgeAsMinter, USDCBridgeDeployTestBase) {
        USDCBridgeDeployTestBase.setUp();
    }
    
    function testRemoveBridgeAsMinter() public {
        vm.selectFork(citreaForkId);
        address mockUSDCBridge = address(new DestinationOUSDCHarness(CITREA_LZ_ENDPOINT, FiatTokenV2_2(CITREA_USDC)));
        address masterMinterOwner = MasterMinter(CITREA_MM).owner();
        require(masterMinterOwner != address(0), "MasterMinter owner not set");
        vm.startPrank(masterMinterOwner);
        MasterMinter(CITREA_MM).configureController(masterMinterOwner, mockUSDCBridge);
        MasterMinter(CITREA_MM).configureMinter(type(uint256).max);
        uint256 amountToMint = 1000 * 10**6;
        address recipient = makeAddr("recipient");
        DestinationOUSDCHarness(mockUSDCBridge).credit(recipient, amountToMint, ethEID);
        assertEq(FiatTokenV2_2(CITREA_USDC).balanceOf(recipient), amountToMint, "Recipient should have received the minted USDC");
        USDCRemoveBridgeAsMinter._run(false, CITREA_MM, masterMinterOwner);
        vm.expectRevert("FiatToken: caller is not a minter");
        DestinationOUSDCHarness(mockUSDCBridge).credit(recipient, amountToMint, ethEID);
    }
}
