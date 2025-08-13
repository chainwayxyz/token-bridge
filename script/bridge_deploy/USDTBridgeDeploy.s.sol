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
        _runEth(true, ethUSDT, ethLzEndpoint, ethUSDTBridgeProxyAdminOwner, ethUSDTBridgeOwner);
        vm.createSelectFork(citreaRPC);
        _runCitrea(true, citreaUSDT, citreaLzEndpoint, citreaUSDTBridgeProxyAdminOwner, citreaUSDTBridgeOwner);
    }

    function _runEth(
        bool broadcast, 
        address _ethUSDT, 
        address _ethLzEndpoint, 
        address _ethUSDTBridgeProxyAdminOwner, 
        address _ethUSDTBridgeOwner
    ) public returns (address) {
        if (broadcast) vm.startBroadcast();
        SourceOFTAdapter ethBridgeImpl = new SourceOFTAdapter(_ethUSDT, _ethLzEndpoint);
        console.log("Ethereum USDT Bridge Implementation:", address(ethBridgeImpl));
        TransparentUpgradeableProxy ethBridgeProxy = new TransparentUpgradeableProxy(
            address(ethBridgeImpl),
            _ethUSDTBridgeProxyAdminOwner,
            abi.encodeWithSignature("initialize(address)", _ethUSDTBridgeOwner)
        );
        console.log("Ethereum USDT Bridge Proxy:", address(ethBridgeProxy));
        if (broadcast) vm.stopBroadcast();
        return address(ethBridgeProxy);
    }

    function _runCitrea(
        bool broadcast,
        address _citreaUSDT,
        address _citreaLzEndpoint,
        address _citreaUSDTBridgeProxyAdminOwner,
        address _citreaUSDTBridgeOwner
    ) public returns (address) {
        if (broadcast) vm.startBroadcast();
        DestinationOUSDT citreaBridgeImpl = new DestinationOUSDT(_citreaLzEndpoint, IOFTToken(_citreaUSDT));
        console.log("Citrea USDT Bridge Implementation:", address(citreaBridgeImpl));
        TransparentUpgradeableProxy citreaBridgeProxy = new TransparentUpgradeableProxy(
            address(citreaBridgeImpl),
            _citreaUSDTBridgeProxyAdminOwner,
            abi.encodeWithSignature("initialize(address)", _citreaUSDTBridgeOwner)
        );
        console.log("Citrea USDT Bridge Proxy:", address(citreaBridgeProxy));
        if (broadcast) vm.stopBroadcast();
        return address(citreaBridgeProxy);
    }
}