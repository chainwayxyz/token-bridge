// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfigSetup} from "../../ConfigSetup.s.sol";
import "openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";

// Taken from https://github.com/circlefin/stablecoin-evm/blob/master/contracts/upgradeability/AdminUpgradeabilityProxy.sol
interface IAdminUpgradeabilityProxy {
    function changeAdmin(address newAdmin) external;
}

contract USDCProxyAdminTransfer is ConfigSetup {
    function setUp() public virtual {
        loadUSDCConfig({isBridgeDeployed: true});
    }

    // Should be called by `dest.usdc.bridge.init.proxyAdminOwner` address
    function run() public {
        vm.createSelectFork(destRPC);
        _run(true, address(destUSDC), vm.envAddress("CIRCLE_USDC_PROXY_ADMIN"));
    }

    function _run(bool broadcast, address _destUSDC, address _circleUSDCProxyAdmin) public {
        if (broadcast) vm.startBroadcast();
        IAdminUpgradeabilityProxy(_destUSDC).changeAdmin(_circleUSDCProxyAdmin);
        if (broadcast) vm.stopBroadcast();
    }
}