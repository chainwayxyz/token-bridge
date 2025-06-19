// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import { USDCBridgeFromEthereum } from "../src/CitreaUSDCBridgeFromEthereumForTakeover.sol";
import { USDCBridgeToCitrea } from "../src/EthereumUSDCBridgeToEthereumForTakeover.sol";
import "openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";

contract USDCBridgePrepareTakeover is Script {
    address public ethProxyAdmin;
    address public ethBridgeProxy;
    string public ethRPC;

    address public citreaProxyAdmin;
    address public citreaBridgeProxy;
    string public citreaRPC;
    
    function setUp() public {
        ethProxyAdmin = vm.envAddress("ETH_PROXY_ADMIN");
        ethBridgeProxy = vm.envAddress("ETH_BRIDGE_PROXY");
        ethRPC = vm.envString("ETH_RPC");

        citreaProxyAdmin = vm.envAddress("CITREA_PROXY_ADMIN");
        citreaBridgeProxy = vm.envAddress("CITREA_BRIDGE_PROXY");
        citreaRPC = vm.envString("CITREA_RPC");
    }

    function run() public {
        vm.createSelectFork(ethRPC);
        vm.startBroadcast();

        address newEthBridgeImpl = address(new USDCBridgeToCitrea());
        ProxyAdmin(ethProxyAdmin).upgradeAndCall(ethBridgeProxy, newEthBridgeImpl, "");
        
        vm.stopBroadcast();

        vm.createSelectFork(citreaRPC);
        vm.startBroadcast();

        address newCitreaBridgeImpl = address(new USDCBridgeFromEthereum());
        ProxyAdmin(citreaProxyAdmin).upgradeAndCall(citreaBridgeProxy, newCitreaBridgeImpl, "");
        
        vm.stopBroadcast();
    }
}