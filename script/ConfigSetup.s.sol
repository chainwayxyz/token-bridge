// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "forge-std/Script.sol";
import {FiatTokenV2_2} from "../src/interfaces/IFiatTokenV2_2.sol";

contract ConfigSetup is Script {
    string public destRPC;
    address public destLzEndpoint;
    uint32 public destEID;

    FiatTokenV2_2 public destUSDC;
    address public destMM;

    address public destUSDCBridgeOwner;
    address public destUSDCBridgeProxyAdminOwner;
    address public destUSDCBridgeImplementation;
    address public destUSDCBridgeProxy;

    address public destUSDTOwner;
    address public destUSDTProxyAdminOwner;
    address public destUSDT;
    
    address public destUSDTBridgeOwner;
    address public destUSDTBridgeProxyAdminOwner;
    address public destUSDTBridgeImplementation;
    address public destUSDTBridgeProxy;


    string public srcRPC;
    address public srcLzEndpoint;
    uint32 public srcEID;

    address public srcUSDC;

    address public srcUSDCBridgeOwner;
    address public srcUSDCBridgeProxyAdminOwner;
    address public srcUSDCBridgeImplementation;
    address public srcUSDCBridgeProxy;

    address public srcUSDT;

    address public srcUSDTBridgeOwner;
    address public srcUSDTBridgeProxyAdminOwner;
    address public srcUSDTBridgeImplementation;
    address public srcUSDTBridgeProxy;

    function loadUSDCConfig(bool isBridgeDeployed) public {
        string memory tomlContent = _loadCommonConfig();
                
        destUSDC = FiatTokenV2_2(vm.parseTomlAddress(tomlContent, ".dest.usdc.proxy"));
        require(address(destUSDC) != address(0), "Destination USDC Proxy is not set in the config file");
        destMM = vm.parseTomlAddress(tomlContent, ".dest.usdc.masterMinter");
        require(destMM != address(0), "Destination USDC Master Minter is not set in the config file");
        destUSDCBridgeOwner = vm.parseTomlAddress(tomlContent, ".dest.usdc.bridge.init.owner");
        require(destUSDCBridgeOwner != address(0), "Destination USDC Bridge Owner is not set in the config file");
        destUSDCBridgeProxyAdminOwner = vm.parseTomlAddress(tomlContent, ".dest.usdc.bridge.init.proxyAdminOwner");
        require(destUSDCBridgeProxyAdminOwner != address(0), "Destination USDC Bridge Proxy Admin Owner is not set in the config file");

        if (isBridgeDeployed) {
            destUSDCBridgeImplementation = vm.parseTomlAddress(tomlContent, ".dest.usdc.bridge.deployment.implementation");
            require(destUSDCBridgeImplementation != address(0), "Destination USDC Bridge Implementation is not set in the config file");
            destUSDCBridgeProxy = vm.parseTomlAddress(tomlContent, ".dest.usdc.bridge.deployment.proxy");
            require(destUSDCBridgeProxy != address(0), "Destination USDC Bridge Proxy is not set in the config file");
        }
        
        srcUSDC = vm.parseTomlAddress(tomlContent, ".src.usdc.proxy");
        require(srcUSDC != address(0), "Source USDC Proxy is not set in the config file");
        srcUSDCBridgeOwner = vm.parseTomlAddress(tomlContent, ".src.usdc.bridge.init.owner");
        require(srcUSDCBridgeOwner != address(0), "Source USDC Bridge Owner is not set in the config file");
        srcUSDCBridgeProxyAdminOwner = vm.parseTomlAddress(tomlContent, ".src.usdc.bridge.init.proxyAdminOwner");
        require(srcUSDCBridgeProxyAdminOwner != address(0), "Source USDC Bridge Proxy Admin Owner is not set in the config file");

        if (isBridgeDeployed) {
            srcUSDCBridgeImplementation = vm.parseTomlAddress(tomlContent, ".src.usdc.bridge.deployment.implementation");
            require(srcUSDCBridgeImplementation != address(0), "Source USDC Bridge Implementation is not set in the config file");
            srcUSDCBridgeProxy = vm.parseTomlAddress(tomlContent, ".src.usdc.bridge.deployment.proxy");
            require(srcUSDCBridgeProxy != address(0), "Source USDC Bridge Proxy is not set in the config file");
        }
    }

    function loadUSDTConfig(bool isUSDTDeployed, bool isBridgeDeployed) public {
        string memory tomlContent = _loadCommonConfig();

        destUSDTOwner = vm.parseTomlAddress(tomlContent, ".dest.usdt.init.owner");
        require(destUSDTOwner != address(0), "Destination USDT Owner is not set in the config file");
        destUSDTProxyAdminOwner = vm.parseTomlAddress(tomlContent, ".dest.usdt.init.proxyAdminOwner");
        require(destUSDTProxyAdminOwner != address(0), "Destination USDT Proxy Admin Owner is not set in the config file");

        if (isUSDTDeployed) {
            destUSDT = vm.parseTomlAddress(tomlContent, ".dest.usdt.deployment.proxy");
            require(destUSDT != address(0), "Destination USDT Proxy is not set in the config file");
            destUSDTBridgeOwner = vm.parseTomlAddress(tomlContent, ".dest.usdt.bridge.init.owner");
            require(destUSDTBridgeOwner != address(0), "Destination USDT Bridge Owner is not set in the config file");
            destUSDTBridgeProxyAdminOwner = vm.parseTomlAddress(tomlContent, ".dest.usdt.bridge.init.proxyAdminOwner");
            require(destUSDTBridgeProxyAdminOwner != address(0), "Destination USDT Bridge Proxy Admin Owner is not set in the config file");

            srcUSDT = vm.parseTomlAddress(tomlContent, ".src.usdt.contract");
            require(srcUSDT != address(0), "Source USDT Contract is not set in the config file");
            srcUSDTBridgeOwner = vm.parseTomlAddress(tomlContent, ".src.usdt.bridge.init.owner");
            require(srcUSDTBridgeOwner != address(0), "Source USDT Bridge Owner is not set in the config file");
            srcUSDTBridgeProxyAdminOwner = vm.parseTomlAddress(tomlContent, ".src.usdt.bridge.init.proxyAdminOwner");
            require(srcUSDTBridgeProxyAdminOwner != address(0), "Source USDT Bridge Proxy Admin Owner is not set in the config file");
        }

        if (isBridgeDeployed) {
            destUSDTBridgeImplementation = vm.parseTomlAddress(tomlContent, ".dest.usdt.bridge.deployment.implementation");
            require(destUSDTBridgeImplementation != address(0), "Destination USDT Bridge Implementation is not set in the config file");
            destUSDTBridgeProxy = vm.parseTomlAddress(tomlContent, ".dest.usdt.bridge.deployment.proxy");
            require(destUSDTBridgeProxy != address(0), "Destination USDT Bridge Proxy is not set in the config file");

            srcUSDTBridgeImplementation = vm.parseTomlAddress(tomlContent, ".src.usdt.bridge.deployment.implementation");
            require(srcUSDTBridgeImplementation != address(0), "Source USDT Bridge Implementation is not set in the config file");
            srcUSDTBridgeProxy = vm.parseTomlAddress(tomlContent, ".src.usdt.bridge.deployment.proxy");
            require(srcUSDTBridgeProxy != address(0), "Source USDT Bridge Proxy is not set in the config file");
        }
    }

    function _loadCommonConfig() internal returns (string memory tomlContent){
        string memory testnetConfigPath = "./config/testnet/config.toml";
        string memory tomlPath = vm.envOr("CONFIG_PATH", testnetConfigPath);
        tomlContent = vm.readFile(tomlPath);
                
        destRPC = vm.parseTomlString(tomlContent, ".dest.rpc");
        require(bytes(destRPC).length > 0, "Destination RPC is not set in the config file");
        destLzEndpoint = vm.parseTomlAddress(tomlContent, ".dest.lz.endpoint");
        require(destLzEndpoint != address(0), "Destination LayerZero Endpoint is not set in the config file");
        destEID = uint32(vm.parseTomlUint(tomlContent, ".dest.lz.eid"));
        require(destEID > 0, "Destination LayerZero EID is not set or invalid in the config file");

        srcRPC = vm.parseTomlString(tomlContent, ".src.rpc");
        require(bytes(srcRPC).length > 0, "Source RPC is not set in the config file");
        srcLzEndpoint = vm.parseTomlAddress(tomlContent, ".src.lz.endpoint");
        require(srcLzEndpoint != address(0), "Source LayerZero Endpoint is not set in the config file");
        srcEID = uint32(vm.parseTomlUint(tomlContent, ".src.lz.eid"));
        require(srcEID > 0, "Source LayerZero EID is not set or invalid in the config file");
    }
}