// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfigSetup} from "../../ConfigSetup.s.sol";
import {DestinationOUSDC, FiatTokenV2_2} from "../../../src/upgrade_to_before_circle_takeover/DestinationOUSDCForTakeover.sol";
import "openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";
import "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {ERC1967Utils} from "openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Utils.sol";

contract USDCDestBridgePrepareTakeover is ConfigSetup {
    function setUp() public virtual {
        loadUSDCConfig({isBridgeDeployed: true});
    }

    // Should be called by `citrea.usdc.bridge.deployment.init.proxyAdminOwner` address
    function run() public virtual {
        vm.createSelectFork(citreaRPC);
        _run(true, citreaLzEndpoint, address(citreaUSDC), citreaUSDCBridgeProxy);
    }

    function _run(bool broadcast, address _citreaLzEndpoint, address _citreaUSDC, address _citreaUSDCBridgeProxy) public {
        if (broadcast) vm.startBroadcast();
        address newCitreaUSDCBridgeImpl = address(new DestinationOUSDC(_citreaLzEndpoint, FiatTokenV2_2(_citreaUSDC)));
        bytes32 proxyAdminBytes = vm.load(_citreaUSDCBridgeProxy, ERC1967Utils.ADMIN_SLOT);
        address citreaUSDCBridgeProxyAdmin = address(uint160(uint256(proxyAdminBytes)));
        ProxyAdmin(citreaUSDCBridgeProxyAdmin).upgradeAndCall(
            ITransparentUpgradeableProxy(_citreaUSDCBridgeProxy), newCitreaUSDCBridgeImpl, ""
        );
        if (broadcast) vm.stopBroadcast();
    }
}
