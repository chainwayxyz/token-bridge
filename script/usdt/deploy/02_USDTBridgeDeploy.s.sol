// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfigSetup} from "../../ConfigSetup.s.sol";
import {SourceOFTAdapter} from "../../../src/SourceOFTAdapter.sol";
import {DestinationOUSDT, IOFTToken} from "../../../src/DestinationOUSDT.sol";
import "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";
import "forge-std/console.sol";

contract USDTBridgeDeploy is ConfigSetup {
    function setUp() public {
        loadUSDTConfig({isUSDTDeployed: true, isBridgeDeployed: false});
    }

    // Can be called by any address
    function run() public {
        vm.createSelectFork(srcRPC);
        address srcBridgeProxy = _runSrc(true, srcUSDT, srcLzEndpoint, srcUSDTBridgeProxyAdminOwner, srcUSDTBridgeOwner);
        saveAddressToConfig(".src.usdt.bridge.deployment.proxy", srcBridgeProxy);
        vm.createSelectFork(destRPC);
        address destBridgeProxy = _runDest(true, destUSDT, destLzEndpoint, destUSDTBridgeProxyAdminOwner, destUSDTBridgeOwner);
        saveAddressToConfig(".dest.usdt.bridge.deployment.proxy", destBridgeProxy);
    }

    function _runSrc(
        bool broadcast, 
        address _srcUSDT, 
        address _srcLzEndpoint, 
        address _srcUSDTBridgeProxyAdminOwner, 
        address _srcUSDTBridgeOwner
    ) public returns (address) {
        if (broadcast) vm.startBroadcast();
        SourceOFTAdapter srcBridgeImpl = new SourceOFTAdapter(_srcUSDT, _srcLzEndpoint);
        console.log("Source USDT Bridge Implementation:", address(srcBridgeImpl));
        TransparentUpgradeableProxy srcBridgeProxy = new TransparentUpgradeableProxy(
            address(srcBridgeImpl),
            _srcUSDTBridgeProxyAdminOwner,
            abi.encodeWithSignature("initialize(address)", _srcUSDTBridgeOwner)
        );
        console.log("Source USDT Bridge Proxy:", address(srcBridgeProxy));
        if (broadcast) vm.stopBroadcast();
        return address(srcBridgeProxy);
    }

    function _runDest(
        bool broadcast,
        address _destUSDT,
        address _destLzEndpoint,
        address _destUSDTBridgeProxyAdminOwner,
        address _destUSDTBridgeOwner
    ) public returns (address) {
        if (broadcast) vm.startBroadcast();
        DestinationOUSDT destBridgeImpl = new DestinationOUSDT(_destLzEndpoint, IOFTToken(_destUSDT));
        console.log("Destination USDT Bridge Implementation:", address(destBridgeImpl));
        TransparentUpgradeableProxy destBridgeProxy = new TransparentUpgradeableProxy(
            address(destBridgeImpl),
            _destUSDTBridgeProxyAdminOwner,
            abi.encodeWithSignature("initialize(address)", _destUSDTBridgeOwner)
        );
        console.log("Destination USDT Bridge Proxy:", address(destBridgeProxy));
        if (broadcast) vm.stopBroadcast();
        return address(destBridgeProxy);
    }
}