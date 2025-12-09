// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {WBTCBridgeDeployTestBase} from "./deploy/base/WBTCBridgeDeployBase.t.sol";
import {WBTCOFT} from "../../src/wbtc/WBTCOFT.sol";
import {WBTCOFTAdapter} from "../../src/wbtc/WBTCOFTAdapter.sol";
import {OFTFee} from "../../src/wbtc/OFTFee.sol";
import {OFTFeeAdapter} from "../../src/wbtc/OFTFeeAdapter.sol";
import {IFee} from "lib/devtools/packages/oft-evm/contracts/interfaces/IFee.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract WBTCOFTHarness is WBTCOFT {
    constructor(address _lzEndpoint, address _owner) WBTCOFT("Test", "TEST", _lzEndpoint, _owner) {}

    function debit(address _from, uint256 _amountLD, uint256 _minAmountLD, uint32 _dstEid)
        external
        returns (uint256 amountSentLD, uint256 amountReceivedLD)
    {
        return _debit(_from, _amountLD, _minAmountLD, _dstEid);
    }

    function mint(address _to, uint256 _amount) external {
        _mint(_to, _amount);
    }
}

contract WBTCFeeTest is WBTCBridgeDeployTestBase {
    uint16 public constant BPS_DENOMINATOR = 10_000;

    address public alice = makeAddr("alice");
    address public bob = makeAddr("bob");
    address public feeRecipient = makeAddr("feeRecipient");

    function testDestSetFeeOwner() public {
        vm.selectFork(destForkId);

        vm.prank(deployer);
        destWBTCBridge_.setFeeOwner(feeRecipient);

        assertEq(destWBTCBridge_.feeOwner(), feeRecipient);
    }

    function testDestSetFeeOwnerRevertsIfNotOwner() public {
        vm.selectFork(destForkId);

        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, alice));
        destWBTCBridge_.setFeeOwner(feeRecipient);
    }

    function testDestSetFeeOwnerRevertsIfZeroAddress() public {
        vm.selectFork(destForkId);

        vm.prank(deployer);
        vm.expectRevert(IFee.InvalidFeeOwner.selector);
        destWBTCBridge_.setFeeOwner(address(0));
    }

    function testDestSetDefaultFeeBps() public {
        vm.selectFork(destForkId);

        uint16 feeBps = 100; // 1%

        vm.prank(deployer);
        destWBTCBridge_.setDefaultFeeBps(feeBps);

        assertEq(destWBTCBridge_.defaultFeeBps(), feeBps);
    }

    function testDestSetDefaultFeeBpsRevertsIfNotOwner() public {
        vm.selectFork(destForkId);

        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, alice));
        destWBTCBridge_.setDefaultFeeBps(100);
    }

    function testDestSetDefaultFeeBpsRevertsIfInvalidBps() public {
        vm.selectFork(destForkId);

        vm.prank(deployer);
        vm.expectRevert(IFee.InvalidBps.selector);
        destWBTCBridge_.setDefaultFeeBps(BPS_DENOMINATOR + 1);
    }

    function testDestSetFeeBps() public {
        vm.selectFork(destForkId);

        uint32 dstEid = SRC_EID;
        uint16 feeBps = 50; // 0.5%

        vm.prank(deployer);
        destWBTCBridge_.setFeeBps(dstEid, feeBps, true);

        (uint16 actualFeeBps, bool enabled) = destWBTCBridge_.feeBps(dstEid);
        assertEq(actualFeeBps, feeBps);
        assertTrue(enabled);
    }

    function testDestSetFeeBpsRevertsIfNotOwner() public {
        vm.selectFork(destForkId);

        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, alice));
        destWBTCBridge_.setFeeBps(SRC_EID, 50, true);
    }

    function testDestSetFeeBpsRevertsIfInvalidBps() public {
        vm.selectFork(destForkId);

        vm.prank(deployer);
        vm.expectRevert(IFee.InvalidBps.selector);
        destWBTCBridge_.setFeeBps(SRC_EID, BPS_DENOMINATOR + 1, true);
    }

    function testDestGetFeeWithDefaultBps() public {
        vm.selectFork(destForkId);

        uint16 feeBps = 100; // 1%
        uint256 amount = 1e8; // 1 WBTC

        vm.prank(deployer);
        destWBTCBridge_.setDefaultFeeBps(feeBps);

        uint256 expectedFee = (amount * feeBps) / BPS_DENOMINATOR;
        assertEq(destWBTCBridge_.getFee(SRC_EID, amount), expectedFee);
    }

    function testDestGetFeeWithDestinationSpecificBps() public {
        vm.selectFork(destForkId);

        uint16 defaultFeeBps = 100; // 1%
        uint16 specificFeeBps = 50; // 0.5%
        uint256 amount = 1e8; // 1 WBTC

        vm.startPrank(deployer);
        destWBTCBridge_.setDefaultFeeBps(defaultFeeBps);
        destWBTCBridge_.setFeeBps(SRC_EID, specificFeeBps, true);
        vm.stopPrank();

        uint256 expectedFee = (amount * specificFeeBps) / BPS_DENOMINATOR;
        assertEq(destWBTCBridge_.getFee(SRC_EID, amount), expectedFee);
    }

    function testDestGetFeeUsesDefaultWhenDestinationDisabled() public {
        vm.selectFork(destForkId);

        uint16 defaultFeeBps = 100; // 1%
        uint16 specificFeeBps = 50; // 0.5%
        uint256 amount = 1e8; // 1 WBTC

        vm.startPrank(deployer);
        destWBTCBridge_.setDefaultFeeBps(defaultFeeBps);
        destWBTCBridge_.setFeeBps(SRC_EID, specificFeeBps, false); // disabled
        vm.stopPrank();

        uint256 expectedFee = (amount * defaultFeeBps) / BPS_DENOMINATOR;
        assertEq(destWBTCBridge_.getFee(SRC_EID, amount), expectedFee);
    }

    function testDestGetFeeReturnsZeroWhenNoFeeSet() public {
        vm.selectFork(destForkId);

        uint256 amount = 1e8;
        assertEq(destWBTCBridge_.getFee(SRC_EID, amount), 0);
    }

    function testSrcSetDefaultFeeBps() public {
        vm.selectFork(srcForkId);

        uint16 feeBps = 100; // 1%

        vm.prank(deployer);
        srcWBTCBridge_.setDefaultFeeBps(feeBps);

        assertEq(srcWBTCBridge_.defaultFeeBps(), feeBps);
    }

    function testSrcSetDefaultFeeBpsRevertsIfNotOwner() public {
        vm.selectFork(srcForkId);

        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, alice));
        srcWBTCBridge_.setDefaultFeeBps(100);
    }

    function testSrcSetDefaultFeeBpsRevertsIfInvalidBps() public {
        vm.selectFork(srcForkId);

        vm.prank(deployer);
        vm.expectRevert(IFee.InvalidBps.selector);
        srcWBTCBridge_.setDefaultFeeBps(BPS_DENOMINATOR + 1);
    }

    function testSrcSetFeeBps() public {
        vm.selectFork(srcForkId);

        uint32 dstEid = DEST_EID;
        uint16 feeBps = 50; // 0.5%

        vm.prank(deployer);
        srcWBTCBridge_.setFeeBps(dstEid, feeBps, true);

        (uint16 actualFeeBps, bool enabled) = srcWBTCBridge_.feeBps(dstEid);
        assertEq(actualFeeBps, feeBps);
        assertTrue(enabled);
    }

    function testSrcSetFeeBpsRevertsIfNotOwner() public {
        vm.selectFork(srcForkId);

        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, alice));
        srcWBTCBridge_.setFeeBps(DEST_EID, 50, true);
    }

    function testSrcSetFeeBpsRevertsIfInvalidBps() public {
        vm.selectFork(srcForkId);

        vm.prank(deployer);
        vm.expectRevert(IFee.InvalidBps.selector);
        srcWBTCBridge_.setFeeBps(DEST_EID, BPS_DENOMINATOR + 1, true);
    }

    function testSrcGetFeeWithDefaultBps() public {
        vm.selectFork(srcForkId);

        uint16 feeBps = 100; // 1%
        uint256 amount = 1e8; // 1 WBTC

        vm.prank(deployer);
        srcWBTCBridge_.setDefaultFeeBps(feeBps);

        uint256 expectedFee = (amount * feeBps) / BPS_DENOMINATOR;
        assertEq(srcWBTCBridge_.getFee(DEST_EID, amount), expectedFee);
    }

    function testSrcGetFeeWithDestinationSpecificBps() public {
        vm.selectFork(srcForkId);

        uint16 defaultFeeBps = 100; // 1%
        uint16 specificFeeBps = 50; // 0.5%
        uint256 amount = 1e8; // 1 WBTC

        vm.startPrank(deployer);
        srcWBTCBridge_.setDefaultFeeBps(defaultFeeBps);
        srcWBTCBridge_.setFeeBps(DEST_EID, specificFeeBps, true);
        vm.stopPrank();

        uint256 expectedFee = (amount * specificFeeBps) / BPS_DENOMINATOR;
        assertEq(srcWBTCBridge_.getFee(DEST_EID, amount), expectedFee);
    }

    function testSrcGetFeeUsesDefaultWhenDestinationDisabled() public {
        vm.selectFork(srcForkId);

        uint16 defaultFeeBps = 100; // 1%
        uint16 specificFeeBps = 50; // 0.5%
        uint256 amount = 1e8; // 1 WBTC

        vm.startPrank(deployer);
        srcWBTCBridge_.setDefaultFeeBps(defaultFeeBps);
        srcWBTCBridge_.setFeeBps(DEST_EID, specificFeeBps, false); // disabled
        vm.stopPrank();

        uint256 expectedFee = (amount * defaultFeeBps) / BPS_DENOMINATOR;
        assertEq(srcWBTCBridge_.getFee(DEST_EID, amount), expectedFee);
    }

    function testSrcGetFeeReturnsZeroWhenNoFeeSet() public {
        vm.selectFork(srcForkId);

        uint256 amount = 1e8;
        assertEq(srcWBTCBridge_.getFee(DEST_EID, amount), 0);
    }

    function testSrcWithdrawFeesRevertsWhenNoFees() public {
        vm.selectFork(srcForkId);

        vm.prank(deployer);
        vm.expectRevert(OFTFeeAdapter.NoFeesToWithdraw.selector);
        srcWBTCBridge_.withdrawFees(feeRecipient);
    }

    function testSrcWithdrawFeesRevertsIfNotOwner() public {
        vm.selectFork(srcForkId);

        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, alice));
        srcWBTCBridge_.withdrawFees(feeRecipient);
    }

    function testSrcWithdrawFees() public {
        vm.selectFork(srcForkId);

        uint256 feeAmount = 1e6;
        uint256 balanceBefore = IERC20(SRC_WBTC).balanceOf(feeRecipient);

        vm.store(address(srcWBTCBridge_), bytes32(uint256(6)), bytes32(feeAmount));
        deal(SRC_WBTC, address(srcWBTCBridge_), feeAmount);

        vm.expectEmit(true, true, true, true);
        emit OFTFeeAdapter.FeeWithdrawn(feeRecipient, feeAmount);

        vm.prank(deployer);
        srcWBTCBridge_.withdrawFees(feeRecipient);

        assertEq(srcWBTCBridge_.feeBalance(), 0);
        assertEq(IERC20(SRC_WBTC).balanceOf(feeRecipient), balanceBefore + feeAmount);
    }

    function testDestFeeDebit() public {
        vm.selectFork(destForkId);

        WBTCOFTHarness harness = new WBTCOFTHarness(DEST_LZ_ENDPOINT, deployer);

        uint256 amount = 1e8;
        uint16 feeBps = 100; // 1%
        uint256 expectedFee = (amount * feeBps) / BPS_DENOMINATOR;

        vm.prank(deployer);
        harness.setDefaultFeeBps(feeBps);

        vm.prank(deployer);
        harness.setFeeOwner(feeRecipient);

        harness.mint(alice, amount);

        uint256 feeOwnerBalanceBefore = harness.balanceOf(feeRecipient);

        (uint256 amountSent, uint256 amountReceived) = harness.debit(alice, amount, 0, SRC_EID);

        assertEq(amountSent, amount);
        assertEq(amountReceived, amount - expectedFee);
        assertEq(harness.balanceOf(feeRecipient), feeOwnerBalanceBefore + expectedFee);
        assertEq(harness.balanceOf(alice), 0);
    }

    function testDestMaxFeeBps() public {
        vm.selectFork(destForkId);

        // Set max fee (100%)
        vm.prank(deployer);
        destWBTCBridge_.setDefaultFeeBps(BPS_DENOMINATOR);

        uint256 amount = 1e8;
        assertEq(destWBTCBridge_.getFee(SRC_EID, amount), amount);
    }

    function testSrcMaxFeeBps() public {
        vm.selectFork(srcForkId);

        // Set max fee (100%)
        vm.prank(deployer);
        srcWBTCBridge_.setDefaultFeeBps(BPS_DENOMINATOR);

        uint256 amount = 1e8;
        assertEq(srcWBTCBridge_.getFee(DEST_EID, amount), amount);
    }

    function testDestZeroFeeBps() public {
        vm.selectFork(destForkId);

        vm.prank(deployer);
        destWBTCBridge_.setDefaultFeeBps(0);

        uint256 amount = 1e8;
        assertEq(destWBTCBridge_.getFee(SRC_EID, amount), 0);
    }

    function testSrcZeroFeeBps() public {
        vm.selectFork(srcForkId);

        vm.prank(deployer);
        srcWBTCBridge_.setDefaultFeeBps(0);

        uint256 amount = 1e8;
        assertEq(srcWBTCBridge_.getFee(DEST_EID, amount), 0);
    }
}
