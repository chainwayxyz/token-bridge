// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfigSetup, FiatTokenV2_2} from "../../ConfigSetup.s.sol";
import "forge-std/console.sol";
import {SourceOFTAdapter} from "../../../src/SourceOFTAdapter.sol";
import {DestinationOUSDC} from "../../../src/DestinationOUSDC.sol";
import "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract USDCBridgeDeploy is ConfigSetup {
    function setUp() public {
        loadUSDCConfig({isBridgeDeployed: false});
    }

    // Can be called by any address
    function run() public {
        vm.createSelectFork(srcRPC);
        // Set initial owners as the deployer, transfer later
        address srcBridgeProxy = _runSrc(true, srcUSDC, srcLzEndpoint, srcUSDCBridgeProxyAdminOwner, msg.sender);
        saveAddressToConfig(".src.usdc.bridge.deployment.proxy", srcBridgeProxy);
        vm.createSelectFork(destRPC);
        address destBridgeProxy = _runDest(true, destUSDC, destLzEndpoint, destUSDCBridgeProxyAdminOwner, msg.sender);
        saveAddressToConfig(".dest.usdc.bridge.deployment.proxy", destBridgeProxy);
    }

    function _runSrc(
        bool broadcast, 
        address _srcUSDC, 
        address _srcLzEndpoint, 
        address _srcUSDCBridgeProxyAdminOwner, 
        address _srcUSDCBridgeOwner
    ) public returns (address) {
        if (broadcast) vm.startBroadcast();
        SourceOFTAdapter srcBridgeImpl = new SourceOFTAdapter(_srcUSDC, _srcLzEndpoint);
        console.log("Source USDC Bridge Implementation:", address(srcBridgeImpl));
        TransparentUpgradeableProxy srcBridgeProxy = new TransparentUpgradeableProxy(
            address(srcBridgeImpl),
            _srcUSDCBridgeProxyAdminOwner,
            abi.encodeWithSignature("initialize(address)", _srcUSDCBridgeOwner)
        );
        console.log("Source USDC Bridge Proxy:", address(srcBridgeProxy));
        if (broadcast) vm.stopBroadcast();
        return address(srcBridgeProxy);
    }

    function _runDest(
        bool broadcast, 
        FiatTokenV2_2 _destUSDC, 
        address _destLzEndpoint, 
        address _destUSDCBridgeProxyAdminOwner, 
        address _destUSDCBridgeOwner
    ) public returns (address) {
        if (broadcast) vm.startBroadcast();
        DestinationOUSDC destBridgeImpl = new DestinationOUSDC(_destLzEndpoint, _destUSDC);
        console.log("Destination USDC Bridge Implementation:", address(destBridgeImpl));
        TransparentUpgradeableProxy destBridgeProxy = new TransparentUpgradeableProxy(
            address(destBridgeImpl),
            _destUSDCBridgeProxyAdminOwner,
            abi.encodeWithSignature("initialize(address)", _destUSDCBridgeOwner)
        );
        console.log("Destination USDC Bridge Proxy:", address(destBridgeProxy));
        if (broadcast) vm.stopBroadcast();
        return address(destBridgeProxy);
    }
}