// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfigSetup, FiatTokenV2_2} from "../ConfigSetup.s.sol";
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
        _runEth(true, ethUSDC, ethLzEndpoint, ethUSDCBridgeProxyAdminOwner, ethUSDCBridgeOwner);
        vm.createSelectFork(citreaRPC);
        _runCitrea(true, citreaUSDC, citreaLzEndpoint, citreaUSDCBridgeProxyAdminOwner, citreaUSDCBridgeOwner);
    }

    function _runEth(
        bool broadcast, 
        address _ethUSDC, 
        address _ethLzEndpoint, 
        address _ethUSDCBridgeProxyAdminOwner, 
        address _ethUSDCBridgeOwner
    ) public returns (address) {
        if (broadcast) vm.startBroadcast();
        SourceOFTAdapter ethBridgeImpl = new SourceOFTAdapter(_ethUSDC, _ethLzEndpoint);
        console.log("Ethereum USDC Bridge Implementation:", address(ethBridgeImpl));
        TransparentUpgradeableProxy ethBridgeProxy = new TransparentUpgradeableProxy(
            address(ethBridgeImpl),
            _ethUSDCBridgeProxyAdminOwner,
            abi.encodeWithSignature("initialize(address)", _ethUSDCBridgeOwner)
        );
        console.log("Ethereum USDC Bridge Proxy:", address(ethBridgeProxy));
        if (broadcast) vm.stopBroadcast();
        return address(ethBridgeProxy);
    }

    function _runCitrea(
        bool broadcast, 
        FiatTokenV2_2 _citreaUSDC, 
        address _citreaLzEndpoint, 
        address _citreaUSDCBridgeProxyAdminOwner, 
        address _citreaUSDCBridgeOwner
    ) public returns (address) {
        if (broadcast) vm.startBroadcast();
        DestinationOUSDC citreaBridgeImpl = new DestinationOUSDC(_citreaLzEndpoint, _citreaUSDC);
        console.log("Citrea USDC Bridge Implementation:", address(citreaBridgeImpl));
        TransparentUpgradeableProxy citreaBridgeProxy = new TransparentUpgradeableProxy(
            address(citreaBridgeImpl),
            _citreaUSDCBridgeProxyAdminOwner,
            abi.encodeWithSignature("initialize(address)", _citreaUSDCBridgeOwner)
        );
        console.log("Citrea USDC Bridge Proxy:", address(citreaBridgeProxy));
        if (broadcast) vm.stopBroadcast();
        return address(citreaBridgeProxy);
    }
}