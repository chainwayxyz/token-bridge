// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfigSetup} from "../../ConfigSetup.s.sol";
import {WBTCOFT} from "../../../src/wbtc/WBTCOFT.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {MessagingFee} from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";
import {SendParam} from "@layerzerolabs/oft-evm/contracts/interfaces/IOFT.sol";

contract WBTCBridgeBurnTest is ConfigSetup {
    function setUp() public {
        loadWBTCConfig({isBridgeDeployed: true});
    }

    // Can be called by any address with >= 0.00000001 Destination WBTC balance
    function run() public {
        vm.createSelectFork(destRPC);
        vm.startBroadcast();
        uint256 amount = 1; // 0.00000001 WBTC (1 satoshi)
        SendParam memory sendParam = SendParam({
            dstEid: srcEID,
            to: bytes32(uint256(uint160(msg.sender))),
            amountLD: amount,
            minAmountLD: amount,
            extraOptions: "",
            composeMsg: "",
            oftCmd: ""
        });

        MessagingFee memory fee = WBTCOFT(destWBTCBridge).quoteSend(sendParam, false);
        WBTCOFT(destWBTCBridge).send{value: fee.nativeFee}(sendParam, fee, msg.sender);

        vm.stopBroadcast();
    }
}
