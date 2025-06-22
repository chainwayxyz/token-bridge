// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import { USDCBridgeToCitrea } from "../src/EthereumUSDCBridgeToCitrea.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import { MessagingFee } from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";
import { SendParam } from "@layerzerolabs/oft-evm/contracts/interfaces/IOFT.sol";
import { OptionsBuilder } from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OptionsBuilder.sol";

contract USDCBridgeTest is Script {
    using OptionsBuilder for bytes;

    USDCBridgeToCitrea public ethUSDCBridge;
    string public ethRPC;
    uint32 public citreaEID;

    function setUp() public {
        ethUSDCBridge = USDCBridgeToCitrea(vm.envAddress("ETH_USDC_BRIDGE_PROXY"));
        ethRPC = vm.envString("ETH_RPC");
        citreaEID = uint32(vm.envUint("CITREA_EID"));
    }

    function run() public {
        vm.createSelectFork(ethRPC);
        vm.startBroadcast();
        uint amount = 1 * 10**6;
        IERC20(ethUSDCBridge.token()).approve(address(ethUSDCBridge), amount);
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

        MessagingFee memory fee = ethUSDCBridge.quoteSend(sendParam, false);
        ethUSDCBridge.send{value: fee.nativeFee}(sendParam, fee, msg.sender);

        vm.stopBroadcast();
    }
}