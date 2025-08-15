// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfigSetup} from "../../ConfigSetup.s.sol";
import {SourceOFTAdapter} from "../../../src/for_circle_takeover/SourceOFTAdapterForTakeover.sol";
import "openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";
import "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {ERC1967Utils} from "openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Utils.sol";

contract USDCSrcBridgePrepareTakeover is ConfigSetup {
    function setUp() public virtual {
        loadUSDCConfig({isBridgeDeployed: true});
    }

    // Should be called by `src.usdc.bridge.deployment.init.proxyAdminOwner` address
    function run() public virtual {
        vm.createSelectFork(srcRPC);
        _run(true, srcLzEndpoint, srcUSDC, srcUSDCBridgeProxy);
    }

    function _run(bool broadcast, address _srcLzEndpoint, address _srcUSDC, address _srcUSDCBridgeProxy) public {
        if (broadcast) vm.startBroadcast();
        address newSrcUSDCBridgeImpl = address(new SourceOFTAdapter(_srcUSDC, _srcLzEndpoint));
        bytes32 proxyAdminBytes = vm.load(_srcUSDCBridgeProxy, ERC1967Utils.ADMIN_SLOT);
        address srcUSDCBridgeProxyAdmin = address(uint160(uint256(proxyAdminBytes)));
        ProxyAdmin(srcUSDCBridgeProxyAdmin).upgradeAndCall(
            ITransparentUpgradeableProxy(_srcUSDCBridgeProxy), newSrcUSDCBridgeImpl, ""
        );
        if (broadcast) vm.stopBroadcast();
    }
}
