// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfigSetup} from "../../ConfigSetup.s.sol";
import {WBTCOFTAdapter} from "../../../src/wbtc/WBTCOFTAdapter.sol";
import {MessagingFee} from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";
import {SendParam} from "@layerzerolabs/oft-evm/contracts/interfaces/IOFT.sol";

interface IWBTC {
    function approve(address spender, uint value) external;
}

contract WBTCBridgeMintTest is ConfigSetup {
    function setUp() public {
        loadWBTCConfig({isBridgeDeployed: true});
    }

    // Can be called by any address with >= 0.00000001 Source WBTC balance
    function run() public {
        vm.createSelectFork(srcRPC);
        vm.startBroadcast();
        uint256 amount = 1; // 0.00000001 WBTC (1 satoshi)
        IWBTC(WBTCOFTAdapter(srcWBTCBridge).token()).approve(address(srcWBTCBridge), amount);
        SendParam memory sendParam = SendParam({
            dstEid: destEID,
            to: bytes32(uint256(uint160(msg.sender))),
            amountLD: amount,
            minAmountLD: amount,
            extraOptions: "",
            composeMsg: "",
            oftCmd: ""
        });

        MessagingFee memory fee = WBTCOFTAdapter(srcWBTCBridge).quoteSend(sendParam, false);
        WBTCOFTAdapter(srcWBTCBridge).send{value: fee.nativeFee}(sendParam, fee, msg.sender);

        vm.stopBroadcast();
    }
}
