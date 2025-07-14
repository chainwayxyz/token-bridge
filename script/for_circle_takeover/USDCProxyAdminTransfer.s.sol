// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfigSetup} from "./ConfigSetup.s.sol";
import "openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";

// Taken from https://github.com/circlefin/stablecoin-evm/blob/master/contracts/upgradeability/AdminUpgradeabilityProxy.sol
interface IAdminUpgradeabilityProxy {
    function changeAdmin(address newAdmin) external;
}

contract USDCProxyAdminTransferOwner is ConfigSetup {
    function setUp() public {
        loadUSDCConfig({isBridgeDeployed: true});
    }

    function run() public {
        vm.createSelectFork(citreaRPC);
        vm.startBroadcast();

        IAdminUpgradeabilityProxy(citreaUSDC).changeAdmin(vm.envAddress("CIRCLE_USDC_PROXY_ADMIN"));

        vm.stopBroadcast();
    }
}