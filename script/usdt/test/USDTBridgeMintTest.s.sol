// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfigSetup} from "../../ConfigSetup.s.sol";
import {SourceOFTAdapter} from "../../../src/SourceOFTAdapter.sol";
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

    // Can be called by anyone with >= 1 cent Source USDT balance
    function run() public {
        SourceOFTAdapter srcUSDTBridge = SourceOFTAdapter(srcUSDTBridgeProxy);

        vm.createSelectFork(srcRPC);
        vm.startBroadcast();
        uint256 amount = 1 * 10 ** 4; // 1 cent
        IUSDT(srcUSDTBridge.token()).approve(address(srcUSDTBridge), amount);
        bytes memory _extraOptions = OptionsBuilder.newOptions().addExecutorLzReceiveOption(650000, 0);
        SendParam memory sendParam = SendParam({
            dstEid: destEID,
            to: bytes32(uint256(uint160(msg.sender))),
            amountLD: amount,
            minAmountLD: amount * 9 / 10,
            extraOptions: _extraOptions,
            composeMsg: "",
            oftCmd: ""
        });

        MessagingFee memory fee = srcUSDTBridge.quoteSend(sendParam, false);
        srcUSDTBridge.send{value: fee.nativeFee}(sendParam, fee, msg.sender);

        vm.stopBroadcast();
    }
}
