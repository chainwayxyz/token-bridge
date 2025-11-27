// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {ConfigSetup} from "../../../script/ConfigSetup.s.sol";
import {WBTCOFTAdapter} from "../../../src/wbtc/WBTCOFTAdapter.sol";
import {WBTCOFT} from "../../../src/wbtc/WBTCOFT.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {OptionsBuilder} from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OptionsBuilder.sol";
import {ILayerZeroEndpointV2} from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";
import {UlnConfig} from "@layerzerolabs/lz-evm-messagelib-v2/contracts/uln/UlnBase.sol";

contract WBTCPostDeploymentTest is Test, ConfigSetup {
    using OptionsBuilder for bytes;

    uint8 public constant DEFAULT = 0;
    uint8 public constant NIL_DVN_COUNT = type(uint8).max;
    uint64 public constant NIL_CONFIRMATIONS = type(uint64).max;

    function setUp() public {
        if (!vm.envOr("IS_POST_DEPLOYMENT", false)) {
            return;
        }

        loadWBTCConfig({isBridgeDeployed: true});
    }

    function testPostDeployment() public {
        if (!vm.envOr("IS_POST_DEPLOYMENT", false)) {
            vm.skip(true);
        }

        vm.createSelectFork(srcRPC);

        _assertSrcBridgeProperties();
        _assertSrcLZProperties();

        vm.createSelectFork(destRPC);

        _assertDestBridgeProperties();
        _assertDestLZProperties();
    }

    function _assertSrcBridgeProperties() internal view {
        assertEq(WBTCOFTAdapter(srcWBTCBridge).owner(), srcWBTCBridgeOwner, "Source bridge owner should be set correctly");
        assertEq(address(WBTCOFTAdapter(srcWBTCBridge).token()), address(srcWBTC), "Source WBTC Bridge token is not set correctly");
        assertEq(address(WBTCOFTAdapter(srcWBTCBridge).endpoint()), srcLzEndpoint, "Source WBTC Bridge LZ endpoint is not set correctly");
        bytes32 peer = WBTCOFTAdapter(srcWBTCBridge).peers(destEID);
        assertEq(peer, bytes32(uint256(uint160(destWBTCBridge))), "Source bridge peer should be set to destination WBTC");
    }

    function _assertDestBridgeProperties() internal view {
        assertEq(WBTCOFT(destWBTCBridge).owner(), destWBTCBridgeOwner, "Destination bridge owner should be set correctly");
        assertEq(WBTCOFT(destWBTCBridge).feeOwner(), destWBTCBridgeOwner, "Destination bridge fee owner should be set correctly");
        assertEq(address(WBTCOFT(destWBTCBridge).endpoint()), destLzEndpoint, "Destination WBTC Bridge LZ endpoint is not set correctly");
        bytes32 peer = WBTCOFT(destWBTCBridge).peers(srcEID);
        assertEq(peer, bytes32(uint256(uint160(srcWBTCBridge))), "Destination bridge peer should be set to source bridge");
    }

    function _assertSrcLZProperties() internal view {
        assertEq(ILayerZeroEndpointV2(srcLzEndpoint).getSendLibrary(address(srcWBTCBridge), destEID), srcLzSendUlnLib, "Source WBTC Bridge LZ send library is not set correctly");
        (address receiveLib, ) = ILayerZeroEndpointV2(srcLzEndpoint).getReceiveLibrary(address(srcWBTCBridge), destEID);
        assertEq(receiveLib, srcLzRecvUlnLib, "Source WBTC Bridge LZ receive library is not set correctly");

        UlnConfig memory defaultSendConfig = abi.decode(ILayerZeroEndpointV2(srcLzEndpoint).getConfig(address(0), srcLzSendUlnLib, destEID, ULN_CONFIG_TYPE), (UlnConfig));
        UlnConfig memory defaultRecvConfig = abi.decode(ILayerZeroEndpointV2(srcLzEndpoint).getConfig(address(0), srcLzRecvUlnLib, destEID, ULN_CONFIG_TYPE), (UlnConfig));

        assertEq(keccak256(ILayerZeroEndpointV2(srcLzEndpoint).getConfig(address(srcWBTCBridge), srcLzSendUlnLib, destEID, ULN_CONFIG_TYPE)), keccak256(abi.encode(_processUlnConfig(srcLzSendUlnConfig, defaultSendConfig))), "Source WBTC Bridge LZ send ULN config is not set correctly");
        assertEq(keccak256(ILayerZeroEndpointV2(srcLzEndpoint).getConfig(address(srcWBTCBridge), srcLzRecvUlnLib, destEID, ULN_CONFIG_TYPE)), keccak256(abi.encode(_processUlnConfig(srcLzRecvUlnConfig, defaultRecvConfig))), "Source WBTC Bridge LZ receive ULN config is not set correctly");
        assertEq(WBTCOFTAdapter(srcWBTCBridge).enforcedOptions(destEID, SEND), OptionsBuilder.newOptions().addExecutorLzReceiveOption(srcLzReceiveGas, 0), "Enforced options should be set correctly");
    }

    function _assertDestLZProperties() internal view {
        assertEq(ILayerZeroEndpointV2(destLzEndpoint).getSendLibrary(address(destWBTCBridge), srcEID), destLzSendUlnLib, "Destination WBTC Bridge LZ send library is not set correctly");
        (address receiveLib, ) = ILayerZeroEndpointV2(destLzEndpoint).getReceiveLibrary(address(destWBTCBridge), srcEID);
        assertEq(receiveLib, destLzRecvUlnLib, "Destination WBTC Bridge LZ receive library is not set correctly");

        UlnConfig memory defaultSendConfig = abi.decode(ILayerZeroEndpointV2(destLzEndpoint).getConfig(address(0), destLzSendUlnLib, srcEID, ULN_CONFIG_TYPE), (UlnConfig));
        UlnConfig memory defaultRecvConfig = abi.decode(ILayerZeroEndpointV2(destLzEndpoint).getConfig(address(0), destLzRecvUlnLib, srcEID, ULN_CONFIG_TYPE), (UlnConfig));

        assertEq(keccak256(ILayerZeroEndpointV2(destLzEndpoint).getConfig(address(destWBTCBridge), destLzSendUlnLib, srcEID, ULN_CONFIG_TYPE)), keccak256(abi.encode(_processUlnConfig(destLzSendUlnConfig, defaultSendConfig))), "Destination WBTC Bridge LZ send ULN config is not set correctly");
        assertEq(keccak256(ILayerZeroEndpointV2(destLzEndpoint).getConfig(address(destWBTCBridge), destLzRecvUlnLib, srcEID, ULN_CONFIG_TYPE)), keccak256(abi.encode(_processUlnConfig(destLzRecvUlnConfig, defaultRecvConfig))), "Destination WBTC Bridge LZ receive ULN config is not set correctly");
        assertEq(WBTCOFT(destWBTCBridge).enforcedOptions(srcEID, SEND), OptionsBuilder.newOptions().addExecutorLzReceiveOption(destLzReceiveGas, 0), "Enforced options should be set correctly");
    }

    function _processUlnConfig(UlnConfig memory config, UlnConfig memory defaultConfig) internal pure returns (UlnConfig memory) {
        // 0 indicates default
        if (config.confirmations == DEFAULT) {
            config.confirmations = defaultConfig.confirmations;
        }
        if (config.requiredDVNCount == DEFAULT) {
            config.requiredDVNCount = defaultConfig.requiredDVNCount;
        }
        if (config.optionalDVNCount == DEFAULT) {
            config.optionalDVNCount = defaultConfig.optionalDVNCount;
        }

        // DEFAULT values cannot be NIL by `setDefaultUlnConfigs` of `UlnBase.sol` so it is safe to assume the above part did not set them to NIL
        // NIL indicates 0
        if (config.confirmations == NIL_CONFIRMATIONS) {
            config.confirmations = 0;
        }
        if (config.requiredDVNCount == NIL_DVN_COUNT) {
            config.requiredDVNCount = 0;
        }
        if (config.optionalDVNCount == NIL_DVN_COUNT) {
            config.optionalDVNCount = 0;
        }

        return config;
    }
}
