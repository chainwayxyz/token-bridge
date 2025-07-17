// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfigSetup} from "./ConfigSetup.s.sol";
import "forge-std/console.sol";
import {SourceOFTAdapter} from "../src/SourceOFTAdapter.sol";
import {DestinationOUSDC} from "../src/DestinationOUSDC.sol";
import {MasterMinter} from "../src/interfaces/IMasterMinter.sol";
import {FiatTokenV2_2} from "../src/interfaces/IFiatTokenV2_2.sol";
import "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";

contract USDCBridgeDeploy is ConfigSetup {
    function setUp() public {
        loadUSDCConfig({isBridgeDeployed: false});
    }

    function run() public {
        uint256 ethForkId = vm.createSelectFork(ethRPC);
        vm.startBroadcast();
        SourceOFTAdapter ethBridgeImpl = new SourceOFTAdapter(ethUSDC, ethLzEndpoint);
        console.log("Ethereum USDC Bridge Implementation:", address(ethBridgeImpl));
        TransparentUpgradeableProxy ethBridgeProxy = new TransparentUpgradeableProxy(
            address(ethBridgeImpl),
            ethUSDCBridgeProxyAdminOwner,
            abi.encodeWithSignature("initialize(address)", ethUSDCBridgeOwner)
        );
        console.log("Ethereum USDC Bridge Proxy:", address(ethBridgeProxy));
        vm.stopBroadcast();

        vm.createSelectFork(citreaRPC);
        vm.startBroadcast();
        DestinationOUSDC citreaBridgeImpl = new DestinationOUSDC(citreaLzEndpoint, citreaUSDC);
        console.log("Citrea USDC Bridge Implementation:", address(citreaBridgeImpl));
        TransparentUpgradeableProxy citreaBridgeProxy = new TransparentUpgradeableProxy(
            address(citreaBridgeImpl),
            citreaUSDCBridgeProxyAdminOwner,
            abi.encodeWithSignature("initialize(address)", citreaUSDCBridgeOwner)
        );
        console.log("Citrea USDC Bridge Proxy:", address(citreaBridgeProxy));
        MasterMinter(citreaMM).configureController(msg.sender, address(citreaBridgeProxy));
        MasterMinter(citreaMM).configureMinter(type(uint256).max);
        DestinationOUSDC(address(citreaBridgeProxy)).setPeer(ethEID, addressToPeer(address(ethBridgeProxy)));
        vm.stopBroadcast();

        vm.selectFork(ethForkId);
        vm.startBroadcast();
        SourceOFTAdapter(address(ethBridgeProxy)).setPeer(citreaEID, addressToPeer(address(citreaBridgeProxy)));
        vm.stopBroadcast();
    }

    function addressToPeer(address addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(addr)));
    }
}