// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {USDTBridgeDeployTestBase} from "./base/USDTBridgeDeployBase.t.sol";
import {USDTSetBridgeAsMinter} from "../../script/bridge_deploy/USDTSetBridgeAsMinter.s.sol";
import {DestinationOUSDT, IOFTToken} from "../../src/DestinationOUSDT.sol";
import {TetherTokenOFTExtension} from "../../src/interfaces/IOFTExtension.sol";

contract DestinationOUSDTHarness is DestinationOUSDT {
    constructor(address _lzEndpoint, IOFTToken _token) DestinationOUSDT(_lzEndpoint, _token) {}

    function debit(address from, uint256 amountLD, uint256 minAmountLD, uint32 dstEid)
        external
        returns (uint256 amountSentLD, uint256 amountReceivedLD)
    {
        return _debit(from, amountLD, minAmountLD, dstEid);
    }

    function credit(address to, uint256 amountLD, uint32 srcEid) external returns (uint256 amountReceivedLD) {
        return _credit(to, amountLD, srcEid);
    }
}

contract USDTSetBridgeAsMinterTest is USDTBridgeDeployTestBase, USDTSetBridgeAsMinter {
    function setUp() public override (USDTBridgeDeployTestBase, USDTSetBridgeAsMinter) {
        USDTBridgeDeployTestBase.setUp();
    }

    function testSetMinter() public {
        vm.selectFork(citreaForkId);
        vm.startPrank(usdtOwner);
        _run(false, address(usdt), address(citreaUSDTBridge));
        assertEq(TetherTokenOFTExtension(usdt).oftContract(), address(citreaUSDTBridge));
    }

    function testMint() public {
        vm.selectFork(citreaForkId);
        address mockUSDTBridge = address(new DestinationOUSDTHarness(CITREA_LZ_ENDPOINT, IOFTToken(address(usdt))));
        vm.startPrank(usdtOwner);
        _run(false, address(usdt), address(mockUSDTBridge));
        uint256 amountToMint = 1000 * 10**6;
        address recipient = makeAddr("recipient");
        DestinationOUSDTHarness(mockUSDTBridge).credit(recipient, amountToMint, ethEID);
        assertEq(TetherTokenOFTExtension(usdt).balanceOf(recipient), amountToMint, "Recipient should have received the minted USDT");
    }

    function testBridgeCannotMintWithoutSetMinter() public {
        vm.selectFork(citreaForkId);
        DestinationOUSDTHarness mockUSDTBridge = new DestinationOUSDTHarness(CITREA_LZ_ENDPOINT, IOFTToken(address(usdt)));
        address recipient = makeAddr("recipient");
        uint256 amountToMint = 1000 * 10**6;
        vm.expectRevert("Only OFT can call");
        mockUSDTBridge.credit(recipient, amountToMint, ethEID);
    }
}