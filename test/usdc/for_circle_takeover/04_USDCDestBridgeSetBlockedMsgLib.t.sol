// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {USDCDestBridgePrepareTakeoverTestBase, USDCDestBridgePrepareTakeover} from "./base/USDCDestBridgePrepareTakeoverBase.t.sol";
import {USDCDestBridgeSetBlockedMsgLib} from "../../../script/usdc/for_circle_takeover/04_USDCDestBridgeSetBlockedMsgLib.s.sol";
import {DestinationOUSDC} from "../../../src/for_circle_takeover/DestinationOUSDCForTakeover.sol";
import {ILayerZeroEndpointV2} from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";
import {SendParam} from "@layerzerolabs/oft-evm/contracts/interfaces/IOFT.sol";
import {MessagingFee} from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";
import {OptionsBuilder} from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OptionsBuilder.sol";
import {MasterMinter} from "../../../src/interfaces/IMasterMinter.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "forge-std/console.sol";

contract USDCDestBridgeSetBlockedMsgLibTest is USDCDestBridgePrepareTakeoverTestBase, USDCDestBridgeSetBlockedMsgLib {
    using OptionsBuilder for bytes;

    error LZ_NotImplemented();

    address public constant DEST_LZ_BLOCKED_MSG_LIB = 0x926984a57b10a3a5c4CfDBAc04dAAA0309e78932;
    address public user;
    function setUp() public override (USDCDestBridgePrepareTakeoverTestBase, USDCDestBridgeSetBlockedMsgLib) {
        USDCDestBridgePrepareTakeoverTestBase.setUp();
        
        vm.selectFork(destForkId);

        vm.startPrank(destUSDCBridge.owner());
        destUSDCBridge.setPeer(SRC_EID, _addressToPeer(address(srcUSDCBridge)));
        vm.stopPrank();

        _setBridgeAsMinter();

        user = makeAddr("user");
        vm.deal(user, 1 ether);
        deal(destUSDCBridge.token(), user, 1e6);
        vm.startPrank(user);
        IERC20(destUSDCBridge.token()).approve(address(destUSDCBridge), 1e6);
        vm.stopPrank();
    }

    function run() public override (USDCDestBridgePrepareTakeover, USDCDestBridgeSetBlockedMsgLib) {}

    function testCanSendWithoutBlockedMsgLib() public {
        vm.startPrank(user);
        SendParam memory sendParam = _returnSendParam(user);
        MessagingFee memory fee = destUSDCBridge.quoteSend(sendParam, false);
        destUSDCBridge.send{value: fee.nativeFee}(sendParam, fee, user);
    }

    function testSetBlockedMsgLib() public {
        vm.startPrank(destUSDCBridge.owner());
        USDCDestBridgeSetBlockedMsgLib._run(false, DEST_LZ_ENDPOINT, address(destUSDCBridge), SRC_EID, DEST_LZ_BLOCKED_MSG_LIB);
        assertEq(ILayerZeroEndpointV2(DEST_LZ_ENDPOINT).getSendLibrary(address(destUSDCBridge), SRC_EID), DEST_LZ_BLOCKED_MSG_LIB);
        vm.stopPrank();

        vm.startPrank(user);
        SendParam memory sendParam = _returnSendParam(user);
        vm.expectRevert(LZ_NotImplemented.selector);
        MessagingFee memory fee = destUSDCBridge.quoteSend(sendParam, false);
        vm.expectRevert(LZ_NotImplemented.selector);
        destUSDCBridge.send{value: fee.nativeFee}(sendParam, fee, user);
    }

    function _addressToPeer(address addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(addr)));
    }

    function _returnSendParam(address to) internal pure returns (SendParam memory) {
        return
            SendParam({
                dstEid: SRC_EID,
                to: bytes32(uint256(uint160(to))),
                amountLD: 1,
                minAmountLD: 0,
                extraOptions: OptionsBuilder.newOptions().addExecutorLzReceiveOption(650000, 0),
                composeMsg: "",
                oftCmd: ""
            });
    }

    function _setBridgeAsMinter() internal {
        address masterMinterOwner = MasterMinter(DEST_MM).owner();
        require(masterMinterOwner != address(0), "MasterMinter owner not set");
        vm.startPrank(masterMinterOwner);
        MasterMinter(DEST_MM).configureController(masterMinterOwner, address(destUSDCBridge));
        MasterMinter(DEST_MM).configureMinter(type(uint256).max);
        vm.stopPrank();
    }
}
