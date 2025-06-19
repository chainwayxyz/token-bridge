// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";

contract USDCBridgeTest is Script {
    address public citreaUSDCBridge;
    address public citreaUSDC;
    uint32 public citreaEID;
    string public citreaRPC;

    address public ethUSDCBridge;
    address public ethUSDC;
    uint32 public ethEID;
    string public ethRPC;
    address public ethBridgeOwner;
    address public ethProxyAdminOwner;

    function setUp() public {
        citreaUSDC = vm.envAddress("CITREA_USDC");
        citreaLzEndpoint = vm.envAddress("CITREA_LZ_ENDPOINT");
        citreaRPC = vm.envString("CITREA_RPC");
        citreaBridgeOwner = vm.envAddress("CITREA_BRIDGE_OWNER");
        citreaProxyAdminOwner = vm.envAddress("CITREA_PROXY_ADMIN_OWNER");

        ethUSDC = vm.envAddress("ETH_USDC");
        ethEID = uint32(vm.envUint("ETH_EID"));
        ethLzEndpoint = vm.envAddress("ETH_LZ_ENDPOINT");
        ethRPC = vm.envString("ETH_RPC");
        ethBridgeOwner = vm.envAddress("ETH_BRIDGE_OWNER");
        ethProxyAdminOwner = vm.envAddress("ETH_PROXY_ADMIN_OWNER");
    }

    function run() public {
        vm.createSelectFork(ethRPC);
        vm.startBroadcast();
        uint amount = 1 * 10**6;
        IERC20(otherAdapter.token()).approve(address(otherAdapter), amount);
        bytes memory _extraOptions = OptionsBuilder.newOptions().addExecutorLzReceiveOption(650000, 0);
        SendParam memory sendParam = SendParam({
            dstEid: CITREA_EID,
            to: bytes32(uint256(uint160(msg.sender))),
            amountLD: amount,
            minAmountLD: amount * 9 / 10,
            extraOptions: _extraOptions,
            composeMsg: "",
            oftCmd: ""
        });

        MessagingFee memory fee = otherAdapter.quoteSend(sendParam, false);
        otherAdapter.send{value: fee.nativeFee}(sendParam, fee, msg.sender);

        vm.stopBroadcast();
    }
}