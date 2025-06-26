// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import { USDCBridgeFromEthereum } from "../src/CitreaUSDCBridgeFromEthereum.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import { MessagingFee } from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";
import { SendParam } from "@layerzerolabs/oft-evm/contracts/interfaces/IOFT.sol";
import { OptionsBuilder } from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OptionsBuilder.sol";

contract USDCBridgeBurnTest is Script {
    using OptionsBuilder for bytes;

    function run() public {
        USDCBridgeFromEthereum citreaUSDCBridge = USDCBridgeFromEthereum(vm.envAddress("CITREA_BRIDGE_PROXY"));
        string memory citreaRPC = vm.envString("CITREA_RPC");
        uint32 ethEID = uint32(vm.envUint("ETH_EID"));

        vm.createSelectFork(citreaRPC);
        vm.startBroadcast();
        uint256 amount = 1 * 10**4; // 1 cent
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