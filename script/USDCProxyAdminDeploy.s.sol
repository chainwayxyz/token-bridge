// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";

contract USDCProxyAdminDeploy is Script {
    function run() public {
        vm.createSelectFork(vm.envString("CITREA_RPC"));
        vm.startBroadcast();
        
        address citreaUSDCProxyAdminOwner = vm.envAddress("CITREA_USDC_PROXY_ADMIN_OWNER");
        console.log("Citrea USDC Proxy Admin Owner:", address(citreaUSDCProxyAdminOwner));
        ProxyAdmin citreaUSDCProxyAdmin = new ProxyAdmin(citreaUSDCProxyAdminOwner);
        console.log("Citrea USDC Proxy Admin:", address(citreaUSDCProxyAdmin));

        vm.stopBroadcast();
    }
}