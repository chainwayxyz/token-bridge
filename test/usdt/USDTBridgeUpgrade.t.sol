// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {USDTBridgeDeployTestBase} from "./deploy/base/USDTBridgeDeployBase.t.sol";
import {SourceOFTAdapter} from "../../src/SourceOFTAdapter.sol";
import {DestinationOUSDT, IOFTToken} from "../../src/DestinationOUSDT.sol";
import "openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";
import "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {ERC1967Utils} from "openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Utils.sol";

contract UpgradedSourceOFTAdapter is SourceOFTAdapter {
    constructor(address _token, address _lzEndpoint) SourceOFTAdapter(_token, _lzEndpoint) {}

    function newFunction() external pure returns (string memory) {
        return "new function";
    }
}

contract UpgradedDestinationOUSDT is DestinationOUSDT {
    constructor(address _lzEndpoint, IOFTToken _token) DestinationOUSDT(_lzEndpoint, _token) {}

    function newFunction() external pure returns (string memory) {
        return "new function";
    }
}

contract USDTBridgeUpgradeTest is USDTBridgeDeployTestBase {
    function testOwnerCanUpgradeBridge() public {
        vm.selectFork(srcForkId);

        address newSrcUSDTBridgeImpl = address(new UpgradedSourceOFTAdapter(SRC_USDT, SRC_LZ_ENDPOINT));
        bytes32 proxyAdminBytes = vm.load(address(srcUSDTBridge), ERC1967Utils.ADMIN_SLOT);
        address srcUSDTBridgeProxyAdmin = address(uint160(uint256(proxyAdminBytes)));

        vm.startPrank(ProxyAdmin(srcUSDTBridgeProxyAdmin).owner());
        ProxyAdmin(srcUSDTBridgeProxyAdmin).upgradeAndCall(
            ITransparentUpgradeableProxy(address(srcUSDTBridge)), newSrcUSDTBridgeImpl, ""
        );
        vm.stopPrank();

        assertEq(UpgradedSourceOFTAdapter(address(srcUSDTBridge)).newFunction(), "new function");

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