// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfigSetup} from "../../ConfigSetup.s.sol";
import {DestinationOUSDT, IOFTToken} from "../../../src/DestinationOUSDT.sol";
import "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";
import "forge-std/console.sol";

contract USDTDestBridgeDeploy is ConfigSetup {
    function setUp() public {
        loadUSDTConfig({isUSDTDeployed: true, isBridgeDeployed: false});
    }

    // Can be called by any address
    function run() public {
        vm.createSelectFork(destRPC);
        // Set initial owners as the deployer, transfer later
        address destBridgeProxy = _run(true, destUSDT, destLzEndpoint, destUSDTBridgeProxyAdminOwner, msg.sender);
        saveAddressToConfig(".dest.usdt.bridge.deployment.proxy", destBridgeProxy);
    }

    function _run(
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