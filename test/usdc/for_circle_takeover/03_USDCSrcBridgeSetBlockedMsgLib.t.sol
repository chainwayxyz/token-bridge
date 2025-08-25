// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {USDCSrcBridgePrepareTakeoverTestBase, USDCSrcBridgePrepareTakeover} from "./base/USDCSrcBridgePrepareTakeoverBase.t.sol";
import {USDCSrcBridgeSetBlockedMsgLib} from "../../../script/usdc/for_circle_takeover/03_USDCSrcBridgeSetBlockedMsgLib.s.sol";
import {SourceOFTAdapter} from "../../../src/for_circle_takeover/SourceOFTAdapterForTakeover.sol";
import {ILayerZeroEndpointV2} from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";
import {SendParam} from "@layerzerolabs/oft-evm/contracts/interfaces/IOFT.sol";
import {MessagingFee} from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";
import {OptionsBuilder} from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OptionsBuilder.sol";
import "forge-std/console.sol";

contract USDCSrcBridgeSetBlockedMsgLibTest is USDCSrcBridgePrepareTakeoverTestBase, USDCSrcBridgeSetBlockedMsgLib {
    using OptionsBuilder for bytes;

    error LZ_NotImplemented();

    address public constant SRC_LZ_BLOCKED_MSG_LIB = 0x0C77d8d771aB35E2E184E7cE127f19CEd31FF8C0;
    address public user;

    function setUp() public override (USDCSrcBridgePrepareTakeoverTestBase, USDCSrcBridgeSetBlockedMsgLib) {
        USDCSrcBridgePrepareTakeoverTestBase.setUp();

        vm.selectFork(srcForkId);

        vm.startPrank(srcUSDCBridge.owner());
        srcUSDCBridge.setPeer(DEST_EID, _addressToPeer(address(destUSDCBridge)));
        vm.stopPrank();
        user = makeAddr("user");
        vm.deal(user, 1 ether);

        vm.startPrank(srcUSDCBridge.owner());
        srcUSDCBridge.setPeer(DEST_EID, _addressToPeer(address(destUSDCBridge)));
        vm.stopPrank();
    }

    function run() public override (USDCSrcBridgePrepareTakeover, USDCSrcBridgeSetBlockedMsgLib) {}

    function testCanSendWithoutBlockedMsgLib() public {
        vm.startPrank(user);
        SendParam memory sendParam = _returnSendParam(user);
        MessagingFee memory fee = srcUSDCBridge.quoteSend(sendParam, false);
        srcUSDCBridge.send{value: fee.nativeFee}(sendParam, fee, user);
    }

    function testSetBlockedMsgLib() public {
        vm.startPrank(srcUSDCBridge.owner());
        USDCSrcBridgeSetBlockedMsgLib._run(false, SRC_LZ_ENDPOINT, address(srcUSDCBridge), DEST_EID, SRC_LZ_BLOCKED_MSG_LIB);
        vm.stopPrank();

        assertEq(ILayerZeroEndpointV2(SRC_LZ_ENDPOINT).getSendLibrary(address(srcUSDCBridge), DEST_EID), SRC_LZ_BLOCKED_MSG_LIB);

        vm.startPrank(user);
        SendParam memory sendParam = _returnSendParam(user);
        vm.expectRevert(LZ_NotImplemented.selector);
        MessagingFee memory fee = srcUSDCBridge.quoteSend(sendParam, false);
        vm.expectRevert(LZ_NotImplemented.selector);
        srcUSDCBridge.send{value: fee.nativeFee}(sendParam, fee, user);
    }

    function _addressToPeer(address addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(addr)));
    }

    function _returnSendParam(address to) internal pure returns (SendParam memory) {
        return
            SendParam({
                dstEid: DEST_EID,
                to: bytes32(uint256(uint160(to))),
                amountLD: 0,
                minAmountLD: 0,
                extraOptions: OptionsBuilder.newOptions().addExecutorLzReceiveOption(650000, 0),
                composeMsg: "",
                oftCmd: ""
            });
    }
}
