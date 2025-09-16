// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {UlnConfig} from "@layerzerolabs/lz-evm-messagelib-v2/contracts/uln/UlnBase.sol";
import {ILayerZeroEndpointV2} from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";
import {USDTBridgeDeployTestBase} from "./base/USDTBridgeDeployBase.t.sol";
import {USDTSrcBridgeSetLzConfig} from "../../../script/usdt/deploy/04_USDTSrcBridgeSetLzConfig.s.sol";
import {SourceOFTAdapter} from "../../../src/SourceOFTAdapter.sol";
import {OptionsBuilder} from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OptionsBuilder.sol";

contract USDTSrcBridgeSetLzConfigTest is USDTBridgeDeployTestBase, USDTSrcBridgeSetLzConfig {
    using OptionsBuilder for bytes;

    address public SRC_SEND_ULN_LIB = 0xcc1ae8Cf5D3904Cef3360A9532B477529b177cCE;
    address public SRC_RECV_ULN_LIB = 0xdAf00F5eE2158dD58E0d3857851c432E34A3A851;
    address public SRC_DVN = 0x120BE7FAbDE72292E2a56240610DB1cA54Ae4000;

    function setUp() public override (USDTBridgeDeployTestBase, USDTSrcBridgeSetLzConfig) {
        USDTBridgeDeployTestBase.setUp();
    }

    function testSetLzConfig() public {
        vm.selectFork(srcForkId);
        vm.startPrank(srcUSDTBridge.owner());
        uint64 confirmations = 5;
        uint8 requiredDVNCount = 1;
        uint8 optionalDVNCount = 2;
        uint8 optionalDVNThreshold = 2;
        address[] memory requiredDVNs = new address[](1);
        requiredDVNs[0] = SRC_DVN;
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
        _run(false, SRC_LZ_ENDPOINT, SRC_SEND_ULN_LIB, ulnConfig, SRC_RECV_ULN_LIB, gracePeriod, ulnConfig, address(srcUSDTBridge), DEST_EID, receiveGas);
        assertEq(ILayerZeroEndpointV2(SRC_LZ_ENDPOINT).getSendLibrary(address(srcUSDTBridge), DEST_EID), SRC_SEND_ULN_LIB);
        (address receiveLib, ) = ILayerZeroEndpointV2(SRC_LZ_ENDPOINT).getReceiveLibrary(address(srcUSDTBridge), DEST_EID);
        assertEq(receiveLib, SRC_RECV_ULN_LIB);
        assertEq(keccak256(ILayerZeroEndpointV2(SRC_LZ_ENDPOINT).getConfig(address(srcUSDTBridge), SRC_SEND_ULN_LIB, DEST_EID, ULN_CONFIG_TYPE)), keccak256(abi.encode(ulnConfig)));
        assertEq(keccak256(ILayerZeroEndpointV2(SRC_LZ_ENDPOINT).getConfig(address(srcUSDTBridge), SRC_RECV_ULN_LIB, DEST_EID, ULN_CONFIG_TYPE)), keccak256(abi.encode(ulnConfig)));
        assertEq(srcUSDTBridge.enforcedOptions(DEST_EID, SEND), OptionsBuilder.newOptions().addExecutorLzReceiveOption(receiveGas, 0), "Enforced options should be set correctly");
    }
}