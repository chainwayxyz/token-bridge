// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfigSetup} from "../ConfigSetup.s.sol";
import "forge-std/console.sol";
import {SourceOFTAdapter} from "../../src/SourceOFTAdapter.sol";
import {DestinationOUSDT, IOFTToken} from "../../src/DestinationOUSDT.sol";
import "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";

contract USDTBridgeDeploy is ConfigSetup {
    function setUp() public {
        loadUSDTConfig({isUSDTDeployed: true, isBridgeDeployed: false});
    }

    // Can be called by any address
    function run() public {
        vm.createSelectFork(ethRPC);
        _runEth(true);
        vm.createSelectFork(citreaRPC);
        _runCitrea(true);
    }

    function _runEth(bool broadcast) public {
        if (broadcast) vm.startBroadcast();
        SourceOFTAdapter ethBridgeImpl = new SourceOFTAdapter(ethUSDT, ethLzEndpoint);
        console.log("Ethereum USDT Bridge Implementation:", address(ethBridgeImpl));
        TransparentUpgradeableProxy ethBridgeProxy = new TransparentUpgradeableProxy(
            address(ethBridgeImpl),
            ethUSDTBridgeProxyAdminOwner,
            abi.encodeWithSignature("initialize(address)", ethUSDTBridgeOwner)
        );
        console.log("Ethereum USDT Bridge Proxy:", address(ethBridgeProxy));
        if (broadcast) vm.stopBroadcast();
    }

    function _runCitrea(bool broadcast) public {
        if (broadcast) vm.startBroadcast();
        DestinationOUSDT citreaBridgeImpl = new DestinationOUSDT(citreaLzEndpoint, IOFTToken(citreaUSDT));
        console.log("Citrea USDT Bridge Implementation:", address(citreaBridgeImpl));
        TransparentUpgradeableProxy citreaBridgeProxy = new TransparentUpgradeableProxy(
            address(citreaBridgeImpl),
            citreaUSDTBridgeProxyAdminOwner,
            abi.encodeWithSignature("initialize(address)", citreaUSDTBridgeOwner)
        );
        console.log("Citrea USDT Bridge Proxy:", address(citreaBridgeProxy));
        if (broadcast) vm.stopBroadcast();
    }
}