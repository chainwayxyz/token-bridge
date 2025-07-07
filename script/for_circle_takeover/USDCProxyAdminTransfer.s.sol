// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";

// Taken from https://github.com/circlefin/stablecoin-evm/blob/master/contracts/upgradeability/AdminUpgradeabilityProxy.sol
interface IAdminUpgradeabilityProxy {
    function changeAdmin(address newAdmin) external;
}

contract USDCProxyAdminTransferOwner is Script {
    function run() public {
        address citreaUSDCProxy = vm.envAddress("CITREA_USDC");
        string memory citreaRPC = vm.envString("CITREA_RPC");

        vm.createSelectFork(citreaRPC);
        vm.startBroadcast();

        IAdminUpgradeabilityProxy(citreaUSDCProxy).changeAdmin(vm.envAddress("CIRCLE_USDC_PROXY_ADMIN"));

        vm.stopBroadcast();
    }
}