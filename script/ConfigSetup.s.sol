// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "forge-std/Script.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";
import {UlnConfig} from "@layerzerolabs/lz-evm-messagelib-v2/contracts/uln/UlnBase.sol";
import {FiatTokenV2_2} from "../src/interfaces/IFiatTokenV2_2.sol";

contract ConfigSetup is Script {
    using SafeCast for uint256;

    uint32 public constant ULN_CONFIG_TYPE = 2;
    uint16 public constant SEND = 1;

    string public destRPC;
    address public destLzEndpoint;
    uint32 public destEID;

    address public destLzSendUlnLib;
    UlnConfig public destLzSendUlnConfig;
    address public destLzRecvUlnLib;
    uint256 public destLzRecvGracePeriod;
    UlnConfig public destLzRecvUlnConfig;
    uint128 public destLzReceiveGas;
    
    address public destUSDCOwner;
    address public destUSDCProxyAdmin;
    string public destUSDCName;
    string public destUSDCSymbol;
    address public destUSDC;
    address public destMM;
    address public destMMOwner;

    address public destUSDCBridgeOwner;
    address public destUSDCBridgeProxyAdminOwner;
    address public destUSDCBridgeProxy;

    address public destUSDTOwner;
    address public destUSDTProxyAdminOwner;
    string public destUSDTName;
    string public destUSDTSymbol;
    address public destUSDT;
    
    address public destUSDTBridgeOwner;
    address public destUSDTBridgeProxyAdminOwner;
    address public destUSDTBridgeProxy;


    string public srcRPC;
    address public srcLzEndpoint;
    uint32 public srcEID;

    address public srcLzSendUlnLib;
    UlnConfig public srcLzSendUlnConfig;
    address public srcLzRecvUlnLib;
    uint256 public srcLzRecvGracePeriod;
    UlnConfig public srcLzRecvUlnConfig;
    uint128 public srcLzReceiveGas;

    address public srcUSDC;

    address public srcUSDCBridgeOwner;
    address public srcUSDCBridgeProxyAdminOwner;
    address public srcUSDCBridgeProxy;

    address public srcUSDT;

    address public srcUSDTBridgeOwner;
    address public srcUSDTBridgeProxyAdminOwner;
    address public srcUSDTBridgeProxy;


    string public tomlPath;

    function loadUSDCConfig(bool isBridgeDeployed) public {
        string memory tomlContent = _loadCommonConfig();
                
        destUSDC = vm.parseTomlAddress(tomlContent, ".dest.usdc.deployment.proxy");
        require(destUSDC != address(0), "Destination USDC Proxy is not set in the config file");
        destUSDCOwner = vm.parseTomlAddress(tomlContent, ".dest.usdc.init.owner");
        require(destUSDCOwner != address(0), "Destination USDC Owner is not set in the config file");
        destUSDCProxyAdmin = vm.parseTomlAddress(tomlContent, ".dest.usdc.init.proxyAdmin");
        require(destUSDCProxyAdmin != address(0), "Destination USDC Proxy Admin is not set in the config file");
        destUSDCName = vm.parseTomlString(tomlContent, ".dest.usdc.init.name");
        require(bytes(destUSDCName).length > 0, "Destination USDC Name is not set in the config file");
        destUSDCSymbol = vm.parseTomlString(tomlContent, ".dest.usdc.init.symbol");
        require(bytes(destUSDCSymbol).length > 0, "Destination USDC Symbol is not set in the config file");
        destMM = vm.parseTomlAddress(tomlContent, ".dest.usdc.deployment.masterMinter");
        require(destMM != address(0), "Destination USDC Master Minter is not set in the config file");
        destMMOwner = vm.parseTomlAddress(tomlContent, ".dest.usdc.init.masterMinterOwner");
        require(destMMOwner != address(0), "Destination USDC Master Minter Owner is not set in the config file");
        destUSDCBridgeOwner = vm.parseTomlAddress(tomlContent, ".dest.usdc.bridge.init.owner");
        require(destUSDCBridgeOwner != address(0), "Destination USDC Bridge Owner is not set in the config file");
        destUSDCBridgeProxyAdminOwner = vm.parseTomlAddress(tomlContent, ".dest.usdc.bridge.init.proxyAdminOwner");
        require(destUSDCBridgeProxyAdminOwner != address(0), "Destination USDC Bridge Proxy Admin Owner is not set in the config file");

        if (isBridgeDeployed) {
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
        destUSDTName = vm.parseTomlString(tomlContent, ".dest.usdt.init.name");
        require(bytes(destUSDTName).length > 0, "Destination USDT Name is not set in the config file");
        destUSDTSymbol = vm.parseTomlString(tomlContent, ".dest.usdt.init.symbol");
        require(bytes(destUSDTSymbol).length > 0, "Destination USDT Symbol is not set in the config file");

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
            destUSDTBridgeProxy = vm.parseTomlAddress(tomlContent, ".dest.usdt.bridge.deployment.proxy");
            require(destUSDTBridgeProxy != address(0), "Destination USDT Bridge Proxy is not set in the config file");

            srcUSDTBridgeProxy = vm.parseTomlAddress(tomlContent, ".src.usdt.bridge.deployment.proxy");
            require(srcUSDTBridgeProxy != address(0), "Source USDT Bridge Proxy is not set in the config file");
        }
    }

    function _loadCommonConfig() internal returns (string memory tomlContent){
        string memory network = vm.envString("NETWORK");
        require(keccak256(bytes(network)) == keccak256(bytes("mainnet")) ||
                keccak256(bytes(network)) == keccak256(bytes("testnet")),
                "NETWORK must be either 'mainnet' or 'testnet'");
        tomlPath = string(abi.encodePacked("./config/", network, "/config.toml"));
        tomlContent = vm.readFile(tomlPath);
                
        destRPC = vm.parseTomlString(tomlContent, ".dest.rpc");
        require(bytes(destRPC).length > 0, "Destination RPC is not set in the config file");
        destLzEndpoint = vm.parseTomlAddress(tomlContent, ".dest.lz.endpoint");
        require(destLzEndpoint != address(0), "Destination LayerZero Endpoint is not set in the config file");
        destEID = uint32(vm.parseTomlUint(tomlContent, ".dest.lz.eid"));
        require(destEID > 0, "Destination LayerZero EID is not set or invalid in the config file");

        destLzSendUlnLib = vm.parseTomlAddress(tomlContent, ".dest.lz.send.ulnLib");
        require(destLzSendUlnLib != address(0), "Destination LayerZero Send ULN Library is not set in the config file");
        destLzSendUlnConfig = _parseUlnConfig(".dest.lz.send");
        destLzRecvUlnLib = vm.parseTomlAddress(tomlContent, ".dest.lz.recv.ulnLib");
        require(destLzRecvUlnLib != address(0), "Destination LayerZero Receive ULN Library is not set in the config file");
        destLzRecvGracePeriod = vm.parseTomlUint(tomlContent, ".dest.lz.recv.gracePeriod");
        destLzRecvUlnConfig = _parseUlnConfig(".dest.lz.recv");
        destLzReceiveGas = vm.parseTomlUint(tomlContent, ".dest.lz.options.receiveGas").toUint128();

        srcRPC = vm.parseTomlString(tomlContent, ".src.rpc");
        require(bytes(srcRPC).length > 0, "Source RPC is not set in the config file");
        srcLzEndpoint = vm.parseTomlAddress(tomlContent, ".src.lz.endpoint");
        require(srcLzEndpoint != address(0), "Source LayerZero Endpoint is not set in the config file");
        srcEID = uint32(vm.parseTomlUint(tomlContent, ".src.lz.eid"));
        require(srcEID > 0, "Source LayerZero EID is not set or invalid in the config file");

        srcLzSendUlnLib = vm.parseTomlAddress(tomlContent, ".src.lz.send.ulnLib");
        require(srcLzSendUlnLib != address(0), "Source LayerZero Send ULN Library is not set in the config file");
        srcLzSendUlnConfig = _parseUlnConfig(".src.lz.send");
        srcLzRecvUlnLib = vm.parseTomlAddress(tomlContent, ".src.lz.recv.ulnLib");
        require(srcLzRecvUlnLib != address(0), "Source LayerZero Receive ULN Library is not set in the config file");
        srcLzRecvGracePeriod = vm.parseTomlUint(tomlContent, ".src.lz.recv.gracePeriod");
        srcLzRecvUlnConfig = _parseUlnConfig(".src.lz.recv");
        srcLzReceiveGas = vm.parseTomlUint(tomlContent, ".src.lz.options.receiveGas").toUint128();

        require(destLzSendUlnConfig.confirmations == srcLzRecvUlnConfig.confirmations, "Destination Send ULN confirmations must match Source Receive ULN confirmations");
        require(destLzRecvUlnConfig.confirmations == srcLzSendUlnConfig.confirmations, "Destination Receive ULN confirmations must match Source Send ULN confirmations");
        require(destLzSendUlnConfig.requiredDVNCount == srcLzRecvUlnConfig.requiredDVNCount, "Destination Send ULN required DVN count must match Source Receive ULN required DVN count");
        require(destLzRecvUlnConfig.requiredDVNCount == srcLzSendUlnConfig.requiredDVNCount, "Destination Receive ULN required DVN count must match Source Send ULN required DVN count");
    }

    function _parseUlnConfig(string memory tableName) internal view returns (UlnConfig memory) {
        string memory tomlContent = vm.readFile(tomlPath);
        return UlnConfig({
            confirmations: vm.parseTomlUint(tomlContent, string(abi.encodePacked(tableName, ".confirmations"))).toUint64(),
            requiredDVNCount: vm.parseTomlUint(tomlContent, string(abi.encodePacked(tableName, ".requiredDVNCount"))).toUint8(),
            optionalDVNCount: vm.parseTomlUint(tomlContent, string(abi.encodePacked(tableName, ".optionalDVNCount"))).toUint8(),
            optionalDVNThreshold: vm.parseTomlUint(tomlContent, string(abi.encodePacked(tableName, ".optionalDVNThreshold"))).toUint8(),
            requiredDVNs: vm.parseTomlAddressArray(tomlContent, string(abi.encodePacked(tableName, ".requiredDVNs"))),
            optionalDVNs: vm.parseTomlAddressArray(tomlContent, string(abi.encodePacked(tableName, ".optionalDVNs")))
        });
    }

    function saveAddressToConfig(string memory key, address addr) public {
        // Check there is no data at the key
        string memory tomlContent = vm.readFile(tomlPath);
        string memory existingAddress = vm.parseTomlString(tomlContent, key);
        require(bytes(existingAddress).length == 0, "Cannot overwrite existing address. Run `CleanDeploymentsFromConfig.py <token-name>` to remove existing deployments first.");
        string memory value = vm.toString(addr);
        vm.writeToml(value, tomlPath, key);
    }
}