// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfigSetup} from "../../ConfigSetup.s.sol";
import {WBTCOFT} from "../../../src/wbtc/WBTCOFT.sol";
import {ILayerZeroEndpointV2} from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";
import {UlnConfig} from "@layerzerolabs/lz-evm-messagelib-v2/contracts/uln/UlnBase.sol";
import {SetConfigParam} from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/IMessageLibManager.sol";
import {IOAppOptionsType3, EnforcedOptionParam} from "@layerzerolabs/oapp-evm/contracts/oapp/interfaces/IOAppOptionsType3.sol";
import {OptionsBuilder} from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OptionsBuilder.sol";

import "forge-std/console.sol";

contract WBTCDestBridgeSetLzConfig is ConfigSetup {
    using OptionsBuilder for bytes;

    function setUp() public virtual {
        loadWBTCConfig({isBridgeDeployed: true});
    }

    // Should be called by deployer (or `dest.wbtc.bridge.init.owner` if role transfer is already done)
    function run() public {
        vm.createSelectFork(destRPC);
        _run(true, destLzEndpoint, destLzSendUlnLib, destLzSendUlnConfig, destLzRecvUlnLib, destLzRecvGracePeriod, destLzRecvUlnConfig, destWBTCBridge, srcEID, srcLzReceiveGas);
    }

    function _run(
        bool broadcast,
        address _destLzEndpoint,
        address _destLzSendUlnLib,
        UlnConfig memory _destLzSendUlnConfig,
        address _destLzRecvUlnLib,
        uint256 _destLzRecvGracePeriod,
        UlnConfig memory _destLzRecvUlnConfig,
        address _destWBTCBridge,
        uint32 _srcEID,
        uint128 _srcLzReceiveGas
    ) public {
        if (broadcast) vm.startBroadcast();

        ILayerZeroEndpointV2(_destLzEndpoint).setSendLibrary(_destWBTCBridge, _srcEID, _destLzSendUlnLib);

        SetConfigParam[] memory params = new SetConfigParam[](1);
        params[0] = SetConfigParam(_srcEID, ULN_CONFIG_TYPE, abi.encode(_destLzSendUlnConfig));
        ILayerZeroEndpointV2(_destLzEndpoint).setConfig(_destWBTCBridge, _destLzSendUlnLib, params);

        ILayerZeroEndpointV2(_destLzEndpoint).setReceiveLibrary(_destWBTCBridge, _srcEID, _destLzRecvUlnLib, _destLzRecvGracePeriod);

        params[0] = SetConfigParam(_srcEID, ULN_CONFIG_TYPE, abi.encode(_destLzRecvUlnConfig));
        ILayerZeroEndpointV2(_destLzEndpoint).setConfig(_destWBTCBridge, _destLzRecvUlnLib, params);

        EnforcedOptionParam[] memory options = new EnforcedOptionParam[](1);
        options[0] = EnforcedOptionParam({
            eid: _srcEID,
            msgType: SEND,
            options: OptionsBuilder.newOptions().addExecutorLzReceiveOption(_srcLzReceiveGas, 0)
        });
        WBTCOFT(_destWBTCBridge).setEnforcedOptions(options);

        if (broadcast) vm.stopBroadcast();
    }
}