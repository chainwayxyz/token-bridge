// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfigSetup} from "./ConfigSetup.s.sol";
import {DestinationOUSDC} from "../src/upgrade_to_before_circle_takeover/DestinationOUSDCForTakeover.sol";
import {SourceOFTAdapter} from "../src/upgrade_to_before_circle_takeover/SourceOFTAdapterForTakeover.sol";
import "openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";
import "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract USDCBridgePrepareTakeover is ConfigSetup {
    function setUp() public {
        loadUSDCConfig({isBridgeDeployed: true});
    }

    function run() public {
        vm.createSelectFork(ethRPC);
        vm.startBroadcast();

        address newEthUSDCBridgeImpl = address(new SourceOFTAdapter(ethUSDC, ethLzEndpoint));
        ProxyAdmin(ethUSDCBridgeProxyAdmin).upgradeAndCall(
            ITransparentUpgradeableProxy(ethUSDCBridgeProxy), newEthUSDCBridgeImpl, ""
        );

        vm.stopBroadcast();

        vm.createSelectFork(citreaRPC);
        vm.startBroadcast();

        address newCitreaUSDCBridgeImpl = address(new DestinationOUSDC(citreaUSDC, citreaLzEndpoint));
        ProxyAdmin(citreaUSDCBridgeProxyAdmin).upgradeAndCall(
            ITransparentUpgradeableProxy(citreaUSDCBridgeProxy), newCitreaUSDCBridgeImpl, ""
        );

        vm.stopBroadcast();
    }
}
