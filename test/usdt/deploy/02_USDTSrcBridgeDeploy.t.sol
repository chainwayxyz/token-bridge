// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {USDTBridgeDeployTestBase} from "./base/USDTBridgeDeployBase.t.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {SourceOFTAdapter} from "../../../src/SourceOFTAdapter.sol";
import "openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";
import "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {ERC1967Utils} from "openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Utils.sol";

contract UpgradedSourceOFTAdapter is SourceOFTAdapter {
    constructor(address _token, address _lzEndpoint) SourceOFTAdapter(_token, _lzEndpoint) {}

    function newFunction() external pure returns (string memory) {
        return "new function";
    }
}

contract USDTSrcBridgeDeployTest is USDTBridgeDeployTestBase {
    function testBridgeOwner() public {
        vm.selectFork(srcForkId);
        assertEq(srcUSDTBridge.owner(), deployer, "Owner should be set to deployer initially");
    }

    function testCannotReinitialize() public {
        vm.selectFork(srcForkId);
        vm.expectRevert(Initializable.InvalidInitialization.selector);
        srcUSDTBridge.initialize(makeAddr("arbitrary"));
    }

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
    }
}