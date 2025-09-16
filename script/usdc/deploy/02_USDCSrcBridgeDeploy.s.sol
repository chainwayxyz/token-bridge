// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfigSetup} from "../../ConfigSetup.s.sol";
import "forge-std/console.sol";
import {SourceOFTAdapter} from "../../../src/SourceOFTAdapter.sol";
import "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract USDCSrcBridgeDeploy is ConfigSetup {
    function setUp() public {
        loadUSDCConfig({isBridgeDeployed: false});
    }

    // Can be called by any address
    function run() public {
        vm.createSelectFork(srcRPC);
        // Set initial owners as the deployer, transfer later
        address srcBridgeProxy = _run(true, srcUSDC, srcLzEndpoint, srcUSDCBridgeProxyAdminOwner, msg.sender);
        saveAddressToConfig(".src.usdc.bridge.deployment.proxy", srcBridgeProxy);
    }

    function _run(
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
}