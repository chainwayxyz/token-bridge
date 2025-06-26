// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";

contract USDCProxyAdminTransferOwner is Script {
    function run() public {
        address citreaProxyAdmin = vm.envAddress("CITREA_BRIDGE_PROXY_ADMIN");
        string memory citreaRPC = vm.envString("CITREA_RPC");
        address circleProxyAdminOwner = vm.envAddress("CIRCLE_PROXY_ADMIN_OWNER");

        vm.createSelectFork(citreaRPC);
        vm.startBroadcast();

        ProxyAdmin(citreaProxyAdmin).transferOwnership(circleProxyAdminOwner);

        vm.stopBroadcast();
    }
}