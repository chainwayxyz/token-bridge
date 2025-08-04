// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfigSetup} from "../../ConfigSetup.s.sol";
import {SourceOFTAdapter} from "../../../src/upgrade_to_before_circle_takeover/SourceOFTAdapterForTakeover.sol";
import "openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";
import "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {ERC1967Utils} from "openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Utils.sol";

contract USDCSrcBridgePrepareTakeover is ConfigSetup {
    function setUp() public {
        loadUSDCConfig({isBridgeDeployed: true});
    }

    // Should be called by `eth.usdc.bridge.deployment.init.proxyAdminOwner` address
    function run() public {
        vm.createSelectFork(ethRPC);
        _run(true);
    }

    function _run(bool broadcast) public {
        if (broadcast) vm.startBroadcast();
        address newEthUSDCBridgeImpl = address(new SourceOFTAdapter(ethUSDC, ethLzEndpoint));
        bytes32 ethAdminSlot = vm.load(ethUSDCBridgeProxy, ERC1967Utils.ADMIN_SLOT);
        address ethUSDCBridgeProxyAdmin = address(uint160(uint256(ethAdminSlot)));
        ProxyAdmin(ethUSDCBridgeProxyAdmin).upgradeAndCall(
            ITransparentUpgradeableProxy(ethUSDCBridgeProxy), newEthUSDCBridgeImpl, ""
        );
        if (broadcast) vm.stopBroadcast();
    }
}
