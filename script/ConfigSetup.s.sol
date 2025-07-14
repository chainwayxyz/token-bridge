// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "forge-std/Script.sol";
import {FiatTokenV2_2} from "../src/interfaces/IFiatTokenV2_2.sol";

contract ConfigSetup is Script {
    string public citreaRPC;
    address public citreaLzEndpoint;
    uint32 public citreaEID;
    FiatTokenV2_2 public citreaUSDC;
    address public citreaMM;
    address public citreaUSDCBridgeOwner;
    address public citreaUSDCBridgeProxyAdminOwner;
    address public citreaUSDCBridgeProxyAdmin;
    address public citreaUSDCBridgeImplementation;
    address public citreaUSDCBridgeProxy;
    address public citreaUSDTOwner;
    address public citreaUSDTProxyAdminOwner;
    address public citreaUSDT;
    address public citreaUSDTProxyAdmin;
    address public citreaUSDTBridgeOwner;
    address public citreaUSDTBridgeImplementation;
    address public citreaUSDTBridgeProxy;

    string public ethRPC;
    address public ethLzEndpoint;
    uint32 public ethEID;
    address public ethUSDC;
    address public ethUSDCBridgeOwner;
    address public ethUSDCBridgeProxyAdminOwner;
    address public ethUSDCBridgeProxyAdmin;
    address public ethUSDCBridgeImplementation;
    address public ethUSDCBridgeProxy;
    address public ethUSDT;
    address public ethUSDTBridgeOwner;
    address public ethUSDTBridgeProxyAdminOwner;
    address public ethUSDTBridgeProxyAdmin;
    address public ethUSDTBridgeImplementation;
    address public ethUSDTBridgeProxy;

    function loadUSDCConfig(bool isBridgeDeployed) public {
        string memory tomlContent = loadCommonConfig();
                
        citreaUSDC = FiatTokenV2_2(vm.parseTomlAddress(tomlContent, ".citrea.usdc.proxy"));
        require(address(citreaUSDC) != address(0), "Citrea USDC Proxy is not set in the config file");
        citreaMM = vm.parseTomlAddress(tomlContent, ".citrea.usdc.masterMinter");
        require(citreaMM != address(0), "Citrea USDC Master Minter is not set in the config file");
        citreaUSDCBridgeOwner = vm.parseTomlAddress(tomlContent, ".citrea.usdc.bridge.init.owner");
        require(citreaUSDCBridgeOwner != address(0), "Citrea USDC Bridge Owner is not set in the config file");
        citreaUSDCBridgeProxyAdminOwner = vm.parseTomlAddress(tomlContent, ".citrea.usdc.bridge.init.proxyAdminOwner");
        require(citreaUSDCBridgeProxyAdminOwner != address(0), "Citrea USDC Bridge Proxy Admin Owner is not set in the config file");

        if (isBridgeDeployed) {
            citreaUSDCBridgeProxyAdmin = vm.parseTomlAddress(tomlContent, ".citrea.usdc.bridge.deployment.proxyAdmin");
            require(citreaUSDCBridgeProxyAdmin != address(0), "Citrea USDC Bridge Proxy Admin is not set in the config file");
            citreaUSDCBridgeImplementation = vm.parseTomlAddress(tomlContent, ".citrea.usdc.bridge.deployment.implementation");
            require(citreaUSDCBridgeImplementation != address(0), "Citrea USDC Bridge Implementation is not set in the config file");
            citreaUSDCBridgeProxy = vm.parseTomlAddress(tomlContent, ".citrea.usdc.bridge.deployment.proxy");
            require(citreaUSDCBridgeProxy != address(0), "Citrea USDC Bridge Proxy is not set in the config file");
        }
        
        ethUSDC = vm.parseTomlAddress(tomlContent, ".eth.usdc.proxy");
        require(ethUSDC != address(0), "Ethereum USDC Proxy is not set in the config file");
        ethUSDCBridgeOwner = vm.parseTomlAddress(tomlContent, ".eth.usdc.bridge.init.owner");
        require(ethUSDCBridgeOwner != address(0), "Ethereum USDC Bridge Owner is not set in the config file");
        ethUSDCBridgeProxyAdminOwner = vm.parseTomlAddress(tomlContent, ".eth.usdc.bridge.init.proxyAdminOwner");
        require(ethUSDCBridgeProxyAdminOwner != address(0), "Ethereum USDC Bridge Proxy Admin Owner is not set in the config file");

        if (isBridgeDeployed) {
            ethUSDCBridgeProxyAdmin = vm.parseTomlAddress(tomlContent, ".eth.usdc.bridge.deployment.proxyAdmin");
            require(ethUSDCBridgeProxyAdmin != address(0), "Ethereum USDC Bridge Proxy Admin is not set in the config file");
            ethUSDCBridgeImplementation = vm.parseTomlAddress(tomlContent, ".eth.usdc.bridge.deployment.implementation");
            require(ethUSDCBridgeImplementation != address(0), "Ethereum USDC Bridge Implementation is not set in the config file");
            ethUSDCBridgeProxy = vm.parseTomlAddress(tomlContent, ".eth.usdc.bridge.deployment.proxy");
            require(ethUSDCBridgeProxy != address(0), "Ethereum USDC Bridge Proxy is not set in the config file");
        }
    }

    function loadUSDTConfig(bool isUSDTDeployed, bool isBridgeDeployed) public {
        string memory tomlContent = loadCommonConfig();

        citreaUSDTOwner = vm.parseTomlAddress(tomlContent, ".citrea.usdt.init.owner");
        require(citreaUSDTOwner != address(0), "Citrea USDT Owner is not set in the config file");
        citreaUSDTProxyAdminOwner = vm.parseTomlAddress(tomlContent, ".citrea.usdt.init.proxyAdminOwner");
        require(citreaUSDTProxyAdminOwner != address(0), "Citrea USDT Proxy Admin Owner is not set in the config file");

        if (isUSDTDeployed) {
            citreaUSDT = vm.parseTomlAddress(tomlContent, ".citrea.usdt.deployment.proxy");
            require(citreaUSDT != address(0), "Citrea USDT Proxy is not set in the config file");
            citreaUSDTProxyAdmin = vm.parseTomlAddress(tomlContent, ".citrea.usdt.deployment.proxyAdmin");
            require(citreaUSDTProxyAdmin != address(0), "Citrea USDT Proxy Admin is not set in the config file");
            citreaUSDTBridgeOwner = vm.parseTomlAddress(tomlContent, ".citrea.usdt.bridge.init.owner");
            require(citreaUSDTBridgeOwner != address(0), "Citrea USDT Bridge Owner is not set in the config file");

            ethUSDT = vm.parseTomlAddress(tomlContent, ".eth.usdt.contract");
            require(ethUSDT != address(0), "Ethereum USDT Contract is not set in the config file");
            ethUSDTBridgeOwner = vm.parseTomlAddress(tomlContent, ".eth.usdt.bridge.init.owner");
            require(ethUSDTBridgeOwner != address(0), "Ethereum USDT Bridge Owner is not set in the config file");
            ethUSDTBridgeProxyAdminOwner = vm.parseTomlAddress(tomlContent, ".eth.usdt.bridge.init.proxyAdminOwner");
            require(ethUSDTBridgeProxyAdminOwner != address(0), "Ethereum USDT Bridge Proxy Admin Owner is not set in the config file");
        }

        if (isBridgeDeployed) {
            citreaUSDTBridgeImplementation = vm.parseTomlAddress(tomlContent, ".citrea.usdt.bridge.deployment.implementation");
            require(citreaUSDTBridgeImplementation != address(0), "Citrea USDT Bridge Implementation is not set in the config file");
            citreaUSDTBridgeProxy = vm.parseTomlAddress(tomlContent, ".citrea.usdt.bridge.deployment.proxy");
            require(citreaUSDTBridgeProxy != address(0), "Citrea USDT Bridge Proxy is not set in the config file");

            ethUSDTBridgeProxyAdmin = vm.parseTomlAddress(tomlContent, ".eth.usdt.bridge.deployment.proxyAdmin");
            require(ethUSDTBridgeProxyAdmin != address(0), "Ethereum USDT Bridge Proxy Admin is not set in the config file");
            ethUSDTBridgeImplementation = vm.parseTomlAddress(tomlContent, ".eth.usdt.bridge.deployment.implementation");
            require(ethUSDTBridgeImplementation != address(0), "Ethereum USDT Bridge Implementation is not set in the config file");
            ethUSDTBridgeProxy = vm.parseTomlAddress(tomlContent, ".eth.usdt.bridge.deployment.proxy");
            require(ethUSDTBridgeProxy != address(0), "Ethereum USDT Bridge Proxy is not set in the config file");
        }
    }

    function loadCommonConfig() internal returns (string memory tomlContent){
        string memory testnetConfigPath = "./config/testnet/config.toml";
        string memory tomlPath = vm.envOr("CONFIG_PATH", testnetConfigPath);
        tomlContent = vm.readFile(tomlPath);
                
        citreaRPC = vm.parseTomlString(tomlContent, ".citrea.rpc");
        require(bytes(citreaRPC).length > 0, "Citrea RPC is not set in the config file");
        citreaLzEndpoint = vm.parseTomlAddress(tomlContent, ".citrea.lz.endpoint");
        require(citreaLzEndpoint != address(0), "Citrea LayerZero Endpoint is not set in the config file");
        citreaEID = uint32(vm.parseTomlUint(tomlContent, ".citrea.lz.eid"));
        require(citreaEID > 0, "Citrea LayerZero EID is not set or invalid in the config file");

        ethRPC = vm.parseTomlString(tomlContent, ".eth.rpc");
        require(bytes(ethRPC).length > 0, "Ethereum RPC is not set in the config file");
        ethLzEndpoint = vm.parseTomlAddress(tomlContent, ".eth.lz.endpoint");
        require(ethLzEndpoint != address(0), "Ethereum LayerZero Endpoint is not set in the config file");
        ethEID = uint32(vm.parseTomlUint(tomlContent, ".eth.lz.eid"));
        require(ethEID > 0, "Ethereum LayerZero EID is not set or invalid in the config file");
    }
}