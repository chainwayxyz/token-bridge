// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfigSetup} from "../ConfigSetup.s.sol";
import "forge-std/console.sol";
import {SourceOFTAdapter} from "../../src/SourceOFTAdapter.sol";
import {DestinationOUSDC} from "../../src/DestinationOUSDC.sol";
import "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract USDCBridgeDeploy is ConfigSetup {
    function setUp() public {
        loadUSDCConfig({isBridgeDeployed: false});
    }

    // Can be called by any address
    function run() public {
        vm.createSelectFork(ethRPC);
        vm.startBroadcast();
        SourceOFTAdapter ethBridgeImpl = new SourceOFTAdapter(ethUSDC, ethLzEndpoint);
        console.log("Ethereum USDC Bridge Implementation:", address(ethBridgeImpl));
        TransparentUpgradeableProxy ethBridgeProxy = new TransparentUpgradeableProxy(
            address(ethBridgeImpl),
            ethUSDCBridgeProxyAdminOwner,
            abi.encodeWithSignature("initialize(address)", ethUSDCBridgeOwner)
        );
        console.log("Ethereum USDC Bridge Proxy:", address(ethBridgeProxy));
        vm.stopBroadcast();

        vm.createSelectFork(citreaRPC);
        vm.startBroadcast();
        DestinationOUSDC citreaBridgeImpl = new DestinationOUSDC(citreaLzEndpoint, citreaUSDC);
        console.log("Citrea USDC Bridge Implementation:", address(citreaBridgeImpl));
        TransparentUpgradeableProxy citreaBridgeProxy = new TransparentUpgradeableProxy(
            address(citreaBridgeImpl),
            citreaUSDCBridgeProxyAdminOwner,
            abi.encodeWithSignature("initialize(address)", citreaUSDCBridgeOwner)
        );
        console.log("Citrea USDC Bridge Proxy:", address(citreaBridgeProxy));
        vm.stopBroadcast();
    }
}