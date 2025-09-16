// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {USDTBridgeDeployTestBase} from "./base/USDTBridgeDeployBase.t.sol";
import {USDTSetBridgeAsMinter} from "../../../script/usdt/deploy/06_USDTSetBridgeAsMinter.s.sol";
import {DestinationOUSDT, IOFTToken} from "../../../src/DestinationOUSDT.sol";
import {TetherTokenOFTExtension} from "../../../src/interfaces/IOFTExtension.sol";
import {DestinationOUSDTHarness} from "../mock/DestinationOUSDTHarness.sol";

contract USDTSetBridgeAsMinterTest is USDTBridgeDeployTestBase, USDTSetBridgeAsMinter {
    function setUp() public override (USDTBridgeDeployTestBase, USDTSetBridgeAsMinter) {
        USDTBridgeDeployTestBase.setUp();
    }

    function testSetMinter() public {
        vm.selectFork(destForkId);
        vm.startPrank(deployer);
        _run(false, address(usdt), address(destUSDTBridge));
        assertEq(TetherTokenOFTExtension(usdt).oftContract(), address(destUSDTBridge));
    }

    function testMint() public {
        vm.selectFork(destForkId);
        address mockUSDTBridge = address(new DestinationOUSDTHarness(DEST_LZ_ENDPOINT, IOFTToken(address(usdt))));
        vm.startPrank(deployer);
        _run(false, address(usdt), address(mockUSDTBridge));
        uint256 amountToMint = 1000 * 10**6;
        address recipient = makeAddr("recipient");
        DestinationOUSDTHarness(mockUSDTBridge).credit(recipient, amountToMint, srcEID);
        assertEq(TetherTokenOFTExtension(usdt).balanceOf(recipient), amountToMint, "Recipient should have received the minted USDT");
    }

    function testBridgeCannotMintWithoutSetMinter() public {
        vm.selectFork(destForkId);
        DestinationOUSDTHarness mockUSDTBridge = new DestinationOUSDTHarness(DEST_LZ_ENDPOINT, IOFTToken(address(usdt)));
        address recipient = makeAddr("recipient");
        uint256 amountToMint = 1000 * 10**6;
        vm.expectRevert("Only OFT can call");
        mockUSDTBridge.credit(recipient, amountToMint, srcEID);
    }
}