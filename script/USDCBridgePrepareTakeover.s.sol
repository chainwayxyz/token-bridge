// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import { USDCBridgeFromEthereum } from "../src/upgrade_to_before_circle_takeover/CitreaUSDCBridgeFromEthereumForTakeover.sol";
import { USDCBridgeToCitrea } from "../src/upgrade_to_before_circle_takeover/EthereumUSDCBridgeToCitreaForTakeover.sol";
import "openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";
import "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract USDCBridgePrepareTakeover is Script {
    address public ethProxyAdmin;
    address public ethBridgeProxy;
    address public ethUSDC;
    address public ethLzEndpoint;
    string public ethRPC;

    address public citreaProxyAdmin;
    address public citreaBridgeProxy;
    address public citreaUSDC;
    address public citreaLzEndpoint;
    string public citreaRPC;
    
    function setUp() public {
        ethProxyAdmin = vm.envAddress("ETH_PROXY_ADMIN");
        ethBridgeProxy = vm.envAddress("ETH_BRIDGE_PROXY");
        ethUSDC = vm.envAddress("ETH_USDC");
        ethLzEndpoint = vm.envAddress("ETH_LZ_ENDPOINT");
        ethRPC = vm.envString("ETH_RPC");

        citreaProxyAdmin = vm.envAddress("CITREA_PROXY_ADMIN");
        citreaBridgeProxy = vm.envAddress("CITREA_BRIDGE_PROXY");
        citreaUSDC = vm.envAddress("CITREA_USDC");
        citreaLzEndpoint = vm.envAddress("CITREA_LZ_ENDPOINT");
        citreaRPC = vm.envString("CITREA_RPC");
    }

    function run() public {
        vm.createSelectFork(ethRPC);
        vm.startBroadcast();

        address newEthBridgeImpl = address(new USDCBridgeToCitrea(ethUSDC, ethLzEndpoint));
        ProxyAdmin(ethProxyAdmin).upgradeAndCall(ITransparentUpgradeableProxy(ethBridgeProxy), newEthBridgeImpl, "");
        
        vm.stopBroadcast();

        vm.createSelectFork(citreaRPC);
        vm.startBroadcast();

        address newCitreaBridgeImpl = address(new USDCBridgeFromEthereum(citreaUSDC, citreaLzEndpoint));
        ProxyAdmin(citreaProxyAdmin).upgradeAndCall(ITransparentUpgradeableProxy(citreaBridgeProxy), newCitreaBridgeImpl, "");

        vm.stopBroadcast();
    }
}