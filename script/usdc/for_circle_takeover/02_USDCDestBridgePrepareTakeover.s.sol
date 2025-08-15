// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfigSetup} from "../../ConfigSetup.s.sol";
import {DestinationOUSDC, FiatTokenV2_2} from "../../../src/for_circle_takeover/DestinationOUSDCForTakeover.sol";
import "openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";
import "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {ERC1967Utils} from "openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Utils.sol";

contract USDCDestBridgePrepareTakeover is ConfigSetup {
    function setUp() public virtual {
        loadUSDCConfig({isBridgeDeployed: true});
    }

    // Should be called by `dest.usdc.bridge.deployment.init.proxyAdminOwner` address
    function run() public virtual {
        vm.createSelectFork(destRPC);
        _run(true, destLzEndpoint, address(destUSDC), destUSDCBridgeProxy);
    }

    function _run(bool broadcast, address _destLzEndpoint, address _destUSDC, address _destUSDCBridgeProxy) public {
        if (broadcast) vm.startBroadcast();
        address newDestUSDCBridgeImpl = address(new DestinationOUSDC(_destLzEndpoint, FiatTokenV2_2(_destUSDC)));
        bytes32 proxyAdminBytes = vm.load(_destUSDCBridgeProxy, ERC1967Utils.ADMIN_SLOT);
        address destUSDCBridgeProxyAdmin = address(uint160(uint256(proxyAdminBytes)));
        ProxyAdmin(destUSDCBridgeProxyAdmin).upgradeAndCall(
            ITransparentUpgradeableProxy(_destUSDCBridgeProxy), newDestUSDCBridgeImpl, ""
        );
        if (broadcast) vm.stopBroadcast();
    }
}
