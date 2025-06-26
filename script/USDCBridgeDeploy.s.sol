// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import { USDCBridgeToCitrea } from "../src/EthereumUSDCBridgeToCitrea.sol";
import { USDCBridgeFromEthereum } from "../src/CitreaUSDCBridgeFromEthereum.sol";
import { MasterMinter } from "../src/interfaces/IMasterMinter.sol";
import "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
}

contract USDCBridgeDeploy is Script {
    address public citreaUSDC;
    address public citreaMM;
    address public citreaLzEndpoint;
    uint32 public citreaEID;
    string public citreaRPC;
    address public citreaBridgeOwner;
    address public citreaBridgeProxyAdminOwner;

    address public ethUSDC;
    address public ethLzEndpoint;
    uint32 public ethEID;
    string public ethRPC;
    address public ethBridgeOwner;
    address public ethBridgeProxyAdminOwner;
    
    function setUp() public {
        citreaUSDC = vm.envAddress("CITREA_USDC");
        citreaEID = uint32(vm.envUint("CITREA_EID"));
        citreaMM = vm.envAddress("CITREA_MM");
        citreaLzEndpoint = vm.envAddress("CITREA_LZ_ENDPOINT");
        citreaRPC = vm.envString("CITREA_RPC");
        citreaBridgeOwner = vm.envAddress("CITREA_BRIDGE_OWNER");
        citreaBridgeProxyAdminOwner = vm.envAddress("CITREA_BRIDGE_PROXY_ADMIN_OWNER");

        ethUSDC = vm.envAddress("ETH_USDC");
        ethEID = uint32(vm.envUint("ETH_EID"));
        ethLzEndpoint = vm.envAddress("ETH_LZ_ENDPOINT");
        ethRPC = vm.envString("ETH_RPC");
        ethBridgeOwner = vm.envAddress("ETH_BRIDGE_OWNER");
        ethBridgeProxyAdminOwner = vm.envAddress("ETH_BRIDGE_PROXY_ADMIN_OWNER");
    }

    function run() public {
        uint256 ethForkId = vm.createSelectFork(ethRPC);
        vm.startBroadcast();
        ProxyAdmin ethBridgeProxyAdmin = new ProxyAdmin(ethBridgeProxyAdminOwner);
        console.log("Ethereum USDC Bridge ProxyAdmin:", address(ethBridgeProxyAdmin));
        USDCBridgeToCitrea ethBridgeImpl = new USDCBridgeToCitrea(
            ethUSDC,
            ethLzEndpoint
        );
        console.log("Ethereum USDC Bridge Implementation:", address(ethBridgeImpl));
        TransparentUpgradeableProxy ethBridgeProxy = new TransparentUpgradeableProxy(
            address(ethBridgeImpl),
            address(ethBridgeProxyAdmin),
            abi.encodeWithSignature("initialize(address)", ethBridgeOwner)
        );
        console.log("Ethereum USDC Bridge Proxy:", address(ethBridgeProxy));
        vm.stopBroadcast();

        vm.createSelectFork(citreaRPC);
        vm.startBroadcast();
        ProxyAdmin citreaProxyAdmin = new ProxyAdmin(citreaBridgeProxyAdminOwner);
        console.log("Citrea USDC Bridge ProxyAdmin:", address(citreaProxyAdmin));
        USDCBridgeFromEthereum citreaBridgeImpl = new USDCBridgeFromEthereum(
            citreaUSDC,
            citreaLzEndpoint
        );
        console.log("Citrea USDC Bridge Implementation:", address(citreaBridgeImpl));
        TransparentUpgradeableProxy citreaBridgeProxy = new TransparentUpgradeableProxy(
            address(citreaBridgeImpl),
            address(citreaProxyAdmin),
            abi.encodeWithSignature("initialize(address)", citreaBridgeOwner)
        );
        console.log("Citrea USDC Bridge Proxy:", address(citreaBridgeProxy));
        MasterMinter(citreaMM).configureController(
            msg.sender,
            address(citreaBridgeProxy)
        );
        MasterMinter(citreaMM).configureMinter(type(uint256).max);
        USDCBridgeFromEthereum(address(citreaBridgeProxy)).setPeer(
            ethEID, 
            addressToPeer(address(ethBridgeProxy))
        );
        vm.stopBroadcast();

        vm.selectFork(ethForkId);
        vm.startBroadcast();
        USDCBridgeToCitrea(address(ethBridgeProxy)).setPeer(
            citreaEID,
            addressToPeer(address(citreaBridgeProxy))
        );
        vm.stopBroadcast();
    }

    function addressToPeer(address addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(addr)));
    }
}