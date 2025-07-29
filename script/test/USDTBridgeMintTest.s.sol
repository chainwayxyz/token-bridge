// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfigSetup} from "../ConfigSetup.s.sol";
import {SourceOFTAdapter} from "../../src/SourceOFTAdapter.sol";
import {MessagingFee} from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";
import {SendParam} from "@layerzerolabs/oft-evm/contracts/interfaces/IOFT.sol";
import {OptionsBuilder} from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OptionsBuilder.sol";

interface IUSDT {
    function approve(address spender, uint value) external;
}

contract USDTBridgeMintTest is ConfigSetup {
    using OptionsBuilder for bytes;

    function setUp() public {
        loadUSDTConfig({isUSDTDeployed: true, isBridgeDeployed: true});
    }

    // Can be called by anyone with >= 1 cent Ethereum USDT balance
    function run() public {
        SourceOFTAdapter ethUSDTBridge = SourceOFTAdapter(ethUSDTBridgeProxy);

        vm.createSelectFork(ethRPC);
        vm.startBroadcast();
        uint256 amount = 1 * 10 ** 4; // 1 cent
        IUSDT(ethUSDTBridge.token()).approve(address(ethUSDTBridge), amount);
        bytes memory _extraOptions = OptionsBuilder.newOptions().addExecutorLzReceiveOption(650000, 0);
        SendParam memory sendParam = SendParam({
            dstEid: citreaEID,
            to: bytes32(uint256(uint160(msg.sender))),
            amountLD: amount,
            minAmountLD: amount * 9 / 10,
            extraOptions: _extraOptions,
            composeMsg: "",
            oftCmd: ""
        });

        MessagingFee memory fee = ethUSDTBridge.quoteSend(sendParam, false);
        ethUSDTBridge.send{value: fee.nativeFee}(sendParam, fee, msg.sender);

        vm.stopBroadcast();
    }
}
