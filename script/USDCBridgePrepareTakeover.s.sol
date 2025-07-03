// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import {DestinationOUSDC} from "../src/upgrade_to_before_circle_takeover/CitreaUSDCBridgeFromEthereumForTakeover.sol";
import {SourceOFTAdapter} from "../src/upgrade_to_before_circle_takeover/EthereumUSDCBridgeToCitreaForTakeover.sol";
import "openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";
import "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract USDCBridgePrepareTakeover is Script {
    function run() public {
        address ethBridgeProxyAdmin = vm.envAddress("ETH_BRIDGE_PROXY_ADMIN");
        address ethBridgeProxy = vm.envAddress("ETH_BRIDGE_PROXY");
        address ethUSDC = vm.envAddress("ETH_USDC");
        address ethLzEndpoint = vm.envAddress("ETH_LZ_ENDPOINT");
        string memory ethRPC = vm.envString("ETH_RPC");

        address citreaProxyAdmin = vm.envAddress("CITREA_BRIDGE_PROXY_ADMIN");
        address citreaBridgeProxy = vm.envAddress("CITREA_BRIDGE_PROXY");
        address citreaUSDC = vm.envAddress("CITREA_USDC");
        address citreaLzEndpoint = vm.envAddress("CITREA_LZ_ENDPOINT");
        string memory citreaRPC = vm.envString("CITREA_RPC");

        vm.createSelectFork(ethRPC);
        vm.startBroadcast();

        address newEthBridgeImpl = address(new SourceOFTAdapter(ethUSDC, ethLzEndpoint));
        ProxyAdmin(ethBridgeProxyAdmin).upgradeAndCall(
            ITransparentUpgradeableProxy(ethBridgeProxy), newEthBridgeImpl, ""
        );

        vm.stopBroadcast();

        vm.createSelectFork(citreaRPC);
        vm.startBroadcast();

        address newCitreaBridgeImpl = address(new DestinationOUSDC(citreaUSDC, citreaLzEndpoint));
        ProxyAdmin(citreaProxyAdmin).upgradeAndCall(
            ITransparentUpgradeableProxy(citreaBridgeProxy), newCitreaBridgeImpl, ""
        );

        vm.stopBroadcast();
    }
}
