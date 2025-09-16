// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {USDTBridgeDeployTestBase} from "./base/USDTBridgeDeployBase.t.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {DestinationOUSDT, IOFTToken} from "../../../src/DestinationOUSDT.sol";
import "openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";
import "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {ERC1967Utils} from "openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Utils.sol";

contract UpgradedDestinationOUSDT is DestinationOUSDT {
    constructor(address _lzEndpoint, IOFTToken _token) DestinationOUSDT(_lzEndpoint, _token) {}

    function newFunction() external pure returns (string memory) {
        return "new function";
    }
}

contract USDTBridgeDeployTest is USDTBridgeDeployTestBase {
    function testBridgeOwner() public {
        vm.selectFork(destForkId);
        assertEq(destUSDTBridge.owner(), deployer, "Owner should be set to deployer initially");
    }

    function testCannotReinitialize() public {
        vm.selectFork(destForkId);
        vm.expectRevert(Initializable.InvalidInitialization.selector);
        destUSDTBridge.initialize(makeAddr("arbitrary"));
    }

    function testOwnerCanUpgradeBridge() public {
        vm.selectFork(destForkId);

        address newDestUSDTBridgeImpl = address(new UpgradedDestinationOUSDT(DEST_LZ_ENDPOINT, IOFTToken(address(usdt))));
        bytes32 destProxyAdminBytes = vm.load(address(destUSDTBridge), ERC1967Utils.ADMIN_SLOT);
        address destUSDTBridgeProxyAdmin = address(uint160(uint256(destProxyAdminBytes)));

        vm.startPrank(ProxyAdmin(destUSDTBridgeProxyAdmin).owner());
        ProxyAdmin(destUSDTBridgeProxyAdmin).upgradeAndCall(
            ITransparentUpgradeableProxy(address(destUSDTBridge)), newDestUSDTBridgeImpl, ""
        );
        vm.stopPrank();

        assertEq(UpgradedDestinationOUSDT(address(destUSDTBridge)).newFunction(), "new function");
    }
}