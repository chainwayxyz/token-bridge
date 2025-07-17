// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfigSetup} from "./ConfigSetup.s.sol";
import "forge-std/console.sol";
import {SourceOFTAdapter} from "../src/SourceOFTAdapter.sol";
import {DestinationOUSDT, IOFTToken} from "../src/DestinationOUSDT.sol";
import "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";

contract USDTBridgeDeploy is ConfigSetup {
    function setUp() public {
        loadUSDTConfig({isUSDTDeployed: true, isBridgeDeployed: false});
    }

    function run() public {
        uint256 ethForkId = vm.createSelectFork(ethRPC);
        vm.startBroadcast();
        SourceOFTAdapter ethBridgeImpl = new SourceOFTAdapter(ethUSDT, ethLzEndpoint);
        console.log("Ethereum USDT Bridge Implementation:", address(ethBridgeImpl));
        TransparentUpgradeableProxy ethBridgeProxy = new TransparentUpgradeableProxy(
            address(ethBridgeImpl),
            ethUSDTBridgeProxyAdminOwner,
            abi.encodeWithSignature("initialize(address)", ethUSDTBridgeOwner)
        );
        console.log("Ethereum USDT Bridge Proxy:", address(ethBridgeProxy));
        vm.stopBroadcast();

        vm.createSelectFork(citreaRPC);
        vm.startBroadcast();
        DestinationOUSDT citreaBridgeImpl = new DestinationOUSDT(citreaLzEndpoint, IOFTToken(citreaUSDT));
        console.log("Citrea USDT Bridge Implementation:", address(citreaBridgeImpl));
        TransparentUpgradeableProxy citreaBridgeProxy = new TransparentUpgradeableProxy(
            address(citreaBridgeImpl),
            citreaUSDTBridgeProxyAdminOwner,
            abi.encodeWithSignature("initialize(address)", citreaUSDTBridgeOwner)
        );
        console.log("Citrea USDT Bridge Proxy:", address(citreaBridgeProxy));
        DestinationOUSDT(address(citreaBridgeProxy)).setPeer(ethEID, addressToPeer(address(ethBridgeProxy)));
        vm.stopBroadcast();

        vm.selectFork(ethForkId);
        vm.startBroadcast();
        SourceOFTAdapter(address(ethBridgeProxy)).setPeer(citreaEID, addressToPeer(address(citreaBridgeProxy)));
        vm.stopBroadcast();
    }

    function addressToPeer(address addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(addr)));
    }
}