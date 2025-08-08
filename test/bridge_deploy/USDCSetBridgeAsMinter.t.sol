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
        vm.selectFork(citreaForkId);
        address masterMinterOwner = MasterMinter(CITREA_MM).owner();
        require(masterMinterOwner != address(0), "MasterMinter owner not set");
        vm.startPrank(masterMinterOwner);
        _run(false, masterMinterOwner, CITREA_MM, address(citreaUSDCBridge));
        assertEq(MasterMinter(CITREA_MM).getWorker(masterMinterOwner), address(citreaUSDCBridge), "Worker should be set to the bridge proxy");
    }

    function testMint() public {
        vm.selectFork(citreaForkId);
        address mockUSDCBridge = address(new DestinationOUSDCHarness(CITREA_LZ_ENDPOINT, FiatTokenV2_2(CITREA_USDC)));
        address masterMinterOwner = MasterMinter(CITREA_MM).owner();
        require(masterMinterOwner != address(0), "MasterMinter owner not set");
        vm.startPrank(masterMinterOwner);
        _run(false, masterMinterOwner, CITREA_MM, mockUSDCBridge);
        uint256 amountToMint = 1000 * 10**6;
        address recipient = makeAddr("recipient");
        DestinationOUSDCHarness(mockUSDCBridge).credit(recipient, amountToMint, ethEID);
        assertEq(FiatTokenV2_2(CITREA_USDC).balanceOf(recipient), amountToMint, "Recipient should have received the minted USDC");
    }

    function testBridgeCannotMintWithoutSetMinter() public {
        vm.selectFork(citreaForkId);
        DestinationOUSDCHarness mockUSDCBridge = new DestinationOUSDCHarness(CITREA_LZ_ENDPOINT, FiatTokenV2_2(CITREA_USDC));
        address recipient = makeAddr("recipient");
        uint256 amountToMint = 1000 * 10**6;
        vm.expectRevert("FiatToken: caller is not a minter");
        mockUSDCBridge.credit(recipient, amountToMint, ethEID);
    }
}