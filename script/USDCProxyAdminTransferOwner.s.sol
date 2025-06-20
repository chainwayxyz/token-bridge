// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";

contract USDCProxyAdminTransferOwner is Script {
    address public citreaProxyAdmin;
    string public citreaRPC;
    address public circleProxyAdminOwner;

    function setUp() public {
        citreaProxyAdmin = vm.envAddress("CITREA_PROXY_ADMIN");
        citreaRPC = vm.envString("CITREA_RPC");
        circleProxyAdminOwner = vm.envAddress("CIRCLE_PROXY_ADMIN_OWNER");
    }

    function run() public {
        vm.createSelectFork(citreaRPC);
        vm.startBroadcast();

        ProxyAdmin(citreaProxyAdmin).transferOwnership(circleProxyAdminOwner);

        vm.stopBroadcast();
    }
}