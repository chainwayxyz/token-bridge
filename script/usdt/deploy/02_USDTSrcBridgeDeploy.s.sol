// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfigSetup} from "../../ConfigSetup.s.sol";
import {SourceOFTAdapter} from "../../../src/SourceOFTAdapter.sol";
import "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";
import "forge-std/console.sol";

contract USDTSrcBridgeDeploy is ConfigSetup {
    function setUp() public {
        loadUSDTConfig({isUSDTDeployed: true, isBridgeDeployed: false});
    }

    // Can be called by any address
    function run() public {
        vm.createSelectFork(srcRPC);
        // Set initial owners as the deployer, transfer later
        address srcBridgeProxy = _run(true, srcUSDT, srcLzEndpoint, srcUSDTBridgeProxyAdminOwner, msg.sender);
        saveAddressToConfig(".src.usdt.bridge.deployment.proxy", srcBridgeProxy);
    }

    function _run(
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
}