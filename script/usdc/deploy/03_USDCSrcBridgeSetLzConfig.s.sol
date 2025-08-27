// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfigSetup} from "../../ConfigSetup.s.sol";
import {SourceOFTAdapter} from "../../../src/SourceOFTAdapter.sol";
import {ILayerZeroEndpointV2} from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";
import {UlnConfig} from "@layerzerolabs/lz-evm-messagelib-v2/contracts/uln/UlnBase.sol";
import {SetConfigParam} from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/IMessageLibManager.sol";
import {IOAppOptionsType3, EnforcedOptionParam} from "@layerzerolabs/oapp-evm/contracts/oapp/interfaces/IOAppOptionsType3.sol";
import {OptionsBuilder} from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OptionsBuilder.sol";
import "forge-std/console.sol";

contract USDCSrcBridgeSetLzConfig is ConfigSetup {
    using OptionsBuilder for bytes;

    function setUp() public virtual {
        loadUSDCConfig({isBridgeDeployed: true});
    }

    // Should be called by deployer (or `src.usdc.bridge.init.owner` if role transfer is already done)
    function run() public {
        vm.createSelectFork(srcRPC);
        _run(true, srcLzEndpoint, srcLzSendUlnLib, srcLzSendUlnConfig, srcLzRecvUlnLib, srcLzRecvGracePeriod, srcLzRecvUlnConfig, srcUSDCBridgeProxy, destEID, destLzReceiveGas);
    }

    function _run(
        bool broadcast,
        address _srcLzEndpoint,
        address _srcLzSendUlnLib,
        UlnConfig memory _srcLzSendUlnConfig,
        address _srcLzRecvUlnLib,
        uint256 _srcLzRecvGracePeriod,
        UlnConfig memory _srcLzRecvUlnConfig,
        address _srcUSDCBridgeProxy,
        uint32 _destEID,
        uint128 _destLzReceiveGas
    ) public {
        if (broadcast) vm.startBroadcast();

        ILayerZeroEndpointV2(_srcLzEndpoint).setSendLibrary(_srcUSDCBridgeProxy, _destEID, _srcLzSendUlnLib);
        
        SetConfigParam[] memory params = new SetConfigParam[](1);
        params[0] = SetConfigParam(_destEID, ULN_CONFIG_TYPE, abi.encode(_srcLzSendUlnConfig));
        ILayerZeroEndpointV2(_srcLzEndpoint).setConfig(_srcUSDCBridgeProxy, _srcLzSendUlnLib, params);
        
        ILayerZeroEndpointV2(_srcLzEndpoint).setReceiveLibrary(_srcUSDCBridgeProxy, _destEID, _srcLzRecvUlnLib, _srcLzRecvGracePeriod);

        params[0] = SetConfigParam(_destEID, ULN_CONFIG_TYPE, abi.encode(_srcLzRecvUlnConfig));
        ILayerZeroEndpointV2(_srcLzEndpoint).setConfig(_srcUSDCBridgeProxy, _srcLzRecvUlnLib, params);

        EnforcedOptionParam[] memory options = new EnforcedOptionParam[](1);
        options[0] = EnforcedOptionParam({
            eid: _destEID,
            msgType: SEND,
            options: OptionsBuilder.newOptions().addExecutorLzReceiveOption(_destLzReceiveGas, 0)
        });
        SourceOFTAdapter(_srcUSDCBridgeProxy).setEnforcedOptions(options);

        if (broadcast) vm.stopBroadcast();
    }
}