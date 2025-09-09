// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {USDCBridgeDeployTestBase, FiatTokenV2_2} from "./base/USDCBridgeDeployBase.t.sol";
import {USDCSetBridgeAsMinter} from "../../../script/usdc/deploy/07_USDCSetBridgeAsMinter.s.sol";
import {DestinationOUSDC} from "../../../src/DestinationOUSDC.sol";
import {MasterMinter} from "../../../src/interfaces/IMasterMinter.sol";
import {DestinationOUSDCHarness} from "../mock/DestionationOUSDCHarness.sol";

contract USDCSetBridgeAsMinterTest is USDCBridgeDeployTestBase, USDCSetBridgeAsMinter {
    function setUp() public override (USDCBridgeDeployTestBase, USDCSetBridgeAsMinter) {
        USDCBridgeDeployTestBase.setUp();
    }

    function testSetMinter() public {
        vm.selectFork(destForkId);
        address masterMinterOwner = MasterMinter(DEST_MM).owner();
        require(masterMinterOwner != address(0), "MasterMinter owner not set");
        vm.startPrank(deployer);
        _run(false, masterMinterOwner, DEST_MM, address(destUSDCBridge));
        assertEq(MasterMinter(DEST_MM).getWorker(masterMinterOwner), address(destUSDCBridge), "Worker should be set to the bridge proxy");
    }

    function testMint() public {
        address mockUSDCBridge = _setupBridgeAsMinter();
        uint256 amountToMint = 1000 * 10**6;
        address recipient = makeAddr("recipient");
        DestinationOUSDCHarness(mockUSDCBridge).credit(recipient, amountToMint, srcEID);
        assertEq(FiatTokenV2_2(DEST_USDC).balanceOf(recipient), amountToMint, "Recipient should have received the minted USDC");
    }

    function testMintToZeroAddress() public {
        address mockUSDCBridge = _setupBridgeAsMinter();
        uint256 amountToMint = 1000 * 10**6;
        DestinationOUSDCHarness(mockUSDCBridge).credit(address(0x0), amountToMint, srcEID);
        assertEq(FiatTokenV2_2(DEST_USDC).balanceOf(address(0xdead)), amountToMint, "Dead address should have received the minted USDC");
    }

    function testBridgeCannotMintWithoutSetMinter() public {
        vm.selectFork(destForkId);
        DestinationOUSDCHarness mockUSDCBridge = new DestinationOUSDCHarness(DEST_LZ_ENDPOINT, FiatTokenV2_2(DEST_USDC));
        address recipient = makeAddr("recipient");
        uint256 amountToMint = 1000 * 10**6;
        vm.expectRevert("FiatToken: caller is not a minter");
        mockUSDCBridge.credit(recipient, amountToMint, srcEID);
    }

    function _setupBridgeAsMinter() internal returns (address mockUSDCBridge) {
        vm.selectFork(destForkId);
        mockUSDCBridge = address(new DestinationOUSDCHarness(DEST_LZ_ENDPOINT, FiatTokenV2_2(DEST_USDC)));
        address masterMinterOwner = MasterMinter(DEST_MM).owner();
        require(masterMinterOwner != address(0), "MasterMinter owner not set");
        vm.startPrank(deployer);
        _run(false, masterMinterOwner, DEST_MM, mockUSDCBridge);
    }
}