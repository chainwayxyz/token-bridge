// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfigSetup} from "./ConfigSetup.s.sol";
import "forge-std/console.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";

contract USDTDeploy is ConfigSetup {
    function setUp() public {
        loadUSDTConfig({isUSDTDeployed: false, isBridgeDeployed: false});
    }

    // Can be called by anyone
    function run() public {
        vm.createSelectFork(citreaRPC);
        _run(true);
    }

    function _run(bool broadcast) public returns (address) {
        if (broadcast) vm.startBroadcast();
        // Hack to stop Foundry from complaining about versioning
        bytes memory bytecode = vm.getCode("OFTExtension.sol:TetherTokenOFTExtension");
        address citreaUSDTImpl;
        assembly {
            citreaUSDTImpl := create(0, add(bytecode, 0x20), mload(bytecode))
        }
        console.log("Citrea USDT Implementation:", address(citreaUSDTImpl));
        TransparentUpgradeableProxy citreaUSDTProxy = new TransparentUpgradeableProxy(
            citreaUSDTImpl,
            citreaUSDTProxyAdminOwner,
            abi.encodeWithSignature("initialize(string,string,uint8)", "Bridged USDT (Citrea)", "USDT.e", 6)
        );
        console.log("Citrea USDT Proxy:", address(citreaUSDTProxy));
        Ownable(address(citreaUSDTProxy)).transferOwnership(citreaUSDTOwner);
        if (broadcast) vm.stopBroadcast();
        return address(citreaUSDTProxy);
    }
}