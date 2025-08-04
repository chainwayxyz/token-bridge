// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfigSetup} from "../../ConfigSetup.s.sol";
import {DestinationOUSDC} from "../../../src/upgrade_to_before_circle_takeover/DestinationOUSDCForTakeover.sol";
import "openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";
import "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {ERC1967Utils} from "openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Utils.sol";

contract USDCDestBridgePrepareTakeover is ConfigSetup {
    function setUp() public {
        loadUSDCConfig({isBridgeDeployed: true});
    }

    // Should be called by `citrea.usdc.bridge.deployment.init.proxyAdminOwner` address
    function run() public {
        vm.createSelectFork(citreaRPC);
        _run(true);
    }

    function _run(bool broadcast) public {
        if (broadcast) vm.startBroadcast();
        address newCitreaUSDCBridgeImpl = address(new DestinationOUSDC(citreaLzEndpoint, citreaUSDC));
        bytes32 citreaAdminSlot = vm.load(citreaUSDCBridgeProxy, ERC1967Utils.ADMIN_SLOT);
        address citreaUSDCBridgeProxyAdmin = address(uint160(uint256(citreaAdminSlot)));
        ProxyAdmin(citreaUSDCBridgeProxyAdmin).upgradeAndCall(
            ITransparentUpgradeableProxy(citreaUSDCBridgeProxy), newCitreaUSDCBridgeImpl, ""
        );
        if (broadcast) vm.stopBroadcast();
    }
}
