// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfigSetup} from "../../ConfigSetup.s.sol";
import {DestinationOUSDT} from "../../../src/DestinationOUSDT.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {MessagingFee} from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";
import {SendParam} from "@layerzerolabs/oft-evm/contracts/interfaces/IOFT.sol";

contract USDCBridgeBurnTest is ConfigSetup {
    function setUp() public {
        loadUSDTConfig({isUSDTDeployed: true, isBridgeDeployed: true});
    }

    // Can be called by any address with >= 1 cent Destination USDT balance
    function run() public {
        DestinationOUSDT destUSDTBridge = DestinationOUSDT(destUSDTBridgeProxy);

        vm.createSelectFork(destRPC);
        vm.startBroadcast();
        uint256 amount = 1 * 10 ** 4; // 1 cent
        IERC20(destUSDTBridge.token()).approve(address(destUSDTBridge), amount);
        SendParam memory sendParam = SendParam({
            dstEid: srcEID,
            to: bytes32(uint256(uint160(msg.sender))),
            amountLD: amount,
            minAmountLD: amount,
            extraOptions: "",
            composeMsg: "",
            oftCmd: ""
        });

        MessagingFee memory fee = destUSDTBridge.quoteSend(sendParam, false);
        destUSDTBridge.send{value: fee.nativeFee}(sendParam, fee, msg.sender);

        vm.stopBroadcast();
    }
}
