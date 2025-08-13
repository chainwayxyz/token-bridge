// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {USDCBridgeDeployTestBase, FiatTokenV2_2} from "./base/USDCBridgeDeployBase.t.sol";
import {USDCSetBridgeAsMinter} from "../../script/bridge_deploy/USDCSetBridgeAsMinter.s.sol";
import {DestinationOUSDC} from "../../src/DestinationOUSDC.sol";
import {MasterMinter} from "../../src/interfaces/IMasterMinter.sol";

contract DestinationOUSDCHarness is DestinationOUSDC {
    constructor(address _lzEndpoint, FiatTokenV2_2 _token) DestinationOUSDC(_lzEndpoint, _token) {}

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

contract USDCSetBridgeAsMinterTest is USDCBridgeDeployTestBase, USDCSetBridgeAsMinter {
    function setUp() public override (USDCBridgeDeployTestBase, USDCSetBridgeAsMinter) {
        USDCBridgeDeployTestBase.setUp();
    }

    function testSetMinter() public {
        vm.selectFork(destForkId);
        address masterMinterOwner = MasterMinter(DEST_MM).owner();
        require(masterMinterOwner != address(0), "MasterMinter owner not set");
        vm.startPrank(masterMinterOwner);
        _run(false, masterMinterOwner, DEST_MM, address(destUSDCBridge));
        assertEq(MasterMinter(DEST_MM).getWorker(masterMinterOwner), address(destUSDCBridge), "Worker should be set to the bridge proxy");
    }

    function testMint() public {
        vm.selectFork(destForkId);
        address mockUSDCBridge = address(new DestinationOUSDCHarness(DEST_LZ_ENDPOINT, FiatTokenV2_2(DEST_USDC)));
        address masterMinterOwner = MasterMinter(DEST_MM).owner();
        require(masterMinterOwner != address(0), "MasterMinter owner not set");
        vm.startPrank(masterMinterOwner);
        _run(false, masterMinterOwner, DEST_MM, mockUSDCBridge);
        uint256 amountToMint = 1000 * 10**6;
        address recipient = makeAddr("recipient");
        DestinationOUSDCHarness(mockUSDCBridge).credit(recipient, amountToMint, srcEID);
        assertEq(FiatTokenV2_2(DEST_USDC).balanceOf(recipient), amountToMint, "Recipient should have received the minted USDC");
    }

    function testBridgeCannotMintWithoutSetMinter() public {
        vm.selectFork(destForkId);
        DestinationOUSDCHarness mockUSDCBridge = new DestinationOUSDCHarness(DEST_LZ_ENDPOINT, FiatTokenV2_2(DEST_USDC));
        address recipient = makeAddr("recipient");
        uint256 amountToMint = 1000 * 10**6;
        vm.expectRevert("FiatToken: caller is not a minter");
        mockUSDCBridge.credit(recipient, amountToMint, srcEID);
    }
}