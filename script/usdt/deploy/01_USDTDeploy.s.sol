// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfigSetup} from "../../ConfigSetup.s.sol";
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
        vm.createSelectFork(destRPC);
        _run(true, destUSDTProxyAdminOwner, destUSDTOwner, destUSDTName, destUSDTSymbol);
    }

    function _run(bool broadcast, address _destUSDTProxyAdminOwner, address _destUSDTOwner, string memory _destUSDTName, string memory _destUSDTSymbol) public returns (address) {
        if (broadcast) vm.startBroadcast();
        // Hack to stop Foundry from complaining about versioning
        bytes memory bytecode = vm.getCode("OFTExtension.sol:TetherTokenOFTExtension");
        address destUSDTImpl;
        assembly {
            destUSDTImpl := create(0, add(bytecode, 0x20), mload(bytecode))
        }
        console.log("Destination USDT Implementation:", address(destUSDTImpl));
        TransparentUpgradeableProxy destUSDTProxy = new TransparentUpgradeableProxy(
            destUSDTImpl,
            _destUSDTProxyAdminOwner,
            abi.encodeWithSignature("initialize(string,string,uint8)", _destUSDTName, _destUSDTSymbol, 6)
        );
        console.log("Destination USDT Proxy:", address(destUSDTProxy));
        Ownable(address(destUSDTProxy)).transferOwnership(_destUSDTOwner);
        if (broadcast) vm.stopBroadcast();
        return address(destUSDTProxy);
    }
}