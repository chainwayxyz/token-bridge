// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfigSetup} from "../ConfigSetup.s.sol";
import {DestinationOUSDC} from "../../src/DestinationOUSDC.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {MessagingFee} from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";
import {SendParam} from "@layerzerolabs/oft-evm/contracts/interfaces/IOFT.sol";
import {OptionsBuilder} from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OptionsBuilder.sol";

contract USDCBridgeBurnTest is ConfigSetup {
    using OptionsBuilder for bytes;

    function setUp() public {
        loadUSDCConfig({isBridgeDeployed: true});
    }

    function run() public {
        DestinationOUSDC citreaUSDCBridge = DestinationOUSDC(citreaUSDCBridgeProxy);

        vm.createSelectFork(citreaRPC);
        vm.startBroadcast();
        uint256 amount = 1 * 10 ** 4; // 1 cent
        IERC20(citreaUSDCBridge.token()).approve(address(citreaUSDCBridge), amount);
        bytes memory _extraOptions = OptionsBuilder.newOptions().addExecutorLzReceiveOption(650000, 0);
        SendParam memory sendParam = SendParam({
            dstEid: ethEID,
            to: bytes32(uint256(uint160(msg.sender))),
            amountLD: amount,
            minAmountLD: amount * 9 / 10,
            extraOptions: _extraOptions,
            composeMsg: "",
            oftCmd: ""
        });

        MessagingFee memory fee = citreaUSDCBridge.quoteSend(sendParam, false);
        citreaUSDCBridge.send{value: fee.nativeFee}(sendParam, fee, msg.sender);

        vm.stopBroadcast();
    }
}
