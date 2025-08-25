// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {UlnConfig} from "@layerzerolabs/lz-evm-messagelib-v2/contracts/uln/UlnBase.sol";
import {ILayerZeroEndpointV2} from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";
import {USDCBridgeDeployTestBase} from "./base/USDCBridgeDeployBase.t.sol";
import {USDCDestBridgeSetLzConfig} from "../../../script/usdc/deploy/04_USDCDestBridgeSetLzConfig.s.sol";
import {DestinationOUSDC} from "../../../src/DestinationOUSDC.sol";
import {OptionsBuilder} from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OptionsBuilder.sol";

contract USDCDestBridgeSetLzConfigTest is USDCBridgeDeployTestBase, USDCDestBridgeSetLzConfig {
    using OptionsBuilder for bytes;

    address public DEST_SEND_ULN_LIB = 0xd682ECF100f6F4284138AA925348633B0611Ae21;
    address public DEST_RECV_ULN_LIB = 0xcF1B0F4106B0324F96fEfcC31bA9498caa80701C;
    address public DEST_DVN = 0xe7e778f704EBc0598902cBF96C6748f3B96BC8d1;

    function setUp() public override (USDCBridgeDeployTestBase, USDCDestBridgeSetLzConfig) {
        USDCBridgeDeployTestBase.setUp();
    }

    function testSetLzConfig() public {
        vm.selectFork(destForkId);
        vm.startPrank(destUSDCBridge.owner());
        uint64 confirmations = 5;
        uint8 requiredDVNCount = 1;
        uint8 optionalDVNCount = 2;
        uint8 optionalDVNThreshold = 2;
        address[] memory requiredDVNs = new address[](1);
        requiredDVNs[0] = DEST_DVN;
        address optionalDVN1 = makeAddr("optional1");
        address optionalDVN2 = makeAddr("optional2");
        uint256 gracePeriod = 0;
        uint128 receiveGas = 650000;
        address[] memory optionalDVNs = new address[](2);
        optionalDVNs[0] = optionalDVN2;
        optionalDVNs[1] = optionalDVN1;
        UlnConfig memory ulnConfig = UlnConfig(
            confirmations,
            requiredDVNCount,
            optionalDVNCount,
            optionalDVNThreshold,
            requiredDVNs,
            optionalDVNs
        );
        _run(false, DEST_LZ_ENDPOINT, DEST_SEND_ULN_LIB, ulnConfig, DEST_RECV_ULN_LIB, gracePeriod, ulnConfig, address(destUSDCBridge), SRC_EID, receiveGas);
        assertEq(ILayerZeroEndpointV2(DEST_LZ_ENDPOINT).getSendLibrary(address(destUSDCBridge), SRC_EID), DEST_SEND_ULN_LIB);
        (address receiveLib, ) = ILayerZeroEndpointV2(DEST_LZ_ENDPOINT).getReceiveLibrary(address(destUSDCBridge), SRC_EID);
        assertEq(receiveLib, DEST_RECV_ULN_LIB);
        assertEq(keccak256(ILayerZeroEndpointV2(DEST_LZ_ENDPOINT).getConfig(address(destUSDCBridge), DEST_SEND_ULN_LIB, SRC_EID, ULN_CONFIG_TYPE)), keccak256(abi.encode(ulnConfig)));
        assertEq(keccak256(ILayerZeroEndpointV2(DEST_LZ_ENDPOINT).getConfig(address(destUSDCBridge), DEST_RECV_ULN_LIB, SRC_EID, ULN_CONFIG_TYPE)), keccak256(abi.encode(ulnConfig)));
        assertEq(destUSDCBridge.enforcedOptions(SRC_EID, SEND), OptionsBuilder.newOptions().addExecutorLzReceiveOption(receiveGas, 0), "Enforced options should be set correctly");
    }
}