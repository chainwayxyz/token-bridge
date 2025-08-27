// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {ConfigSetup} from "../../../script/ConfigSetup.s.sol";
import {DestinationOUSDT} from "../../../src/DestinationOUSDT.sol";
import {SourceOFTAdapter} from "../../../src/SourceOFTAdapter.sol";
import {TetherTokenOFTExtension} from "../../../src/interfaces/IOFTExtension.sol";
import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import {ERC1967Utils} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol";
import {OptionsBuilder} from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OptionsBuilder.sol";
import {ILayerZeroEndpointV2} from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";
import {UlnConfig} from "@layerzerolabs/lz-evm-messagelib-v2/contracts/uln/UlnBase.sol";

contract USDTPostDeploymentTest is ConfigSetup, Test {
    using OptionsBuilder for bytes;

    uint8 public constant DEFAULT = 0;
    uint8 public constant NIL_DVN_COUNT = type(uint8).max;
    uint64 public constant NIL_CONFIRMATIONS = type(uint64).max;

    function setUp() public {
        if (!vm.envOr("IS_POST_DEPLOYMENT", false)) {
            return;
        }

        ConfigSetup.loadUSDTConfig(true, true);
    }

    function testPostDeployment() public {
        if (!vm.envOr("IS_POST_DEPLOYMENT", false)) {
            vm.skip(true);
        }

        vm.createSelectFork(srcRPC);

        _assertSrcBridgeProperties();
        _assertSrcLZProperties();

        vm.createSelectFork(destRPC);

        _assertUSDTProperties();
        _assertDestBridgeProperties();
        _assertDestLZProperties();
    }

    function _assertUSDTProperties() internal {
        TetherTokenOFTExtension usdt = TetherTokenOFTExtension(destUSDT);
        assertEq(usdt.owner(), destUSDTOwner, "Destination USDT owner is not set correctly");
        assertEq(usdt.oftContract(), destUSDTBridgeProxy, "Destination USDT OFT contract is not set correctly");
        assertEq(usdt.name(), destUSDTName, "Destination USDT name is not set correctly");
        assertEq(usdt.symbol(), destUSDTSymbol, "Destination USDT symbol is not set correctly");
        assertEq(usdt.decimals(), 6, "Destination USDT decimals should be 6");
        address proxyAdmin = address(uint160(uint256(vm.load(address(destUSDT), ERC1967Utils.ADMIN_SLOT))));
        assertEq(ProxyAdmin(proxyAdmin).owner(), destUSDTProxyAdminOwner, "Destination USDT proxy admin is not set correctly");
        _assertUSDTBlacklistAbility(usdt);
    }

    function _assertUSDTBlacklistAbility(TetherTokenOFTExtension usdt) internal {
        address userToBlacklist = makeAddr("userToBlacklist");
        uint256 initialBalance = 1000 * (10 ** usdt.decimals());
        vm.prank(destUSDTBridgeProxy);
        usdt.crosschainMint(userToBlacklist, initialBalance);
        assertEq(usdt.balanceOf(userToBlacklist), initialBalance, "User should have initial balance");

        vm.prank(userToBlacklist);
        // Verify user can transfer tokens before being blacklisted
        usdt.transfer(address(1), 1);

        vm.prank(destUSDTOwner);
        usdt.addToBlockedList(userToBlacklist);
        assertTrue(usdt.isBlocked(userToBlacklist), "User should be blacklisted");

        vm.startPrank(userToBlacklist);
        vm.expectRevert("TetherToken: from is blocked");
        usdt.transfer(address(1), 1);
        vm.expectRevert("Blocked: msg.sender is blocked");
        usdt.transferFrom(userToBlacklist, address(1), 1);
        vm.stopPrank();

        vm.prank(destUSDTOwner);
        usdt.destroyBlockedFunds(userToBlacklist);
        assertEq(usdt.balanceOf(userToBlacklist), 0, "User balance should be 0 after destroying funds");
    }

    function _assertSrcBridgeProperties() internal view {
        assertEq(SourceOFTAdapter(srcUSDTBridgeProxy).owner(), srcUSDTBridgeOwner, "Source USDT Bridge owner is not set correctly");
        assertEq(address(SourceOFTAdapter(srcUSDTBridgeProxy).token()), address(srcUSDT), "Source USDT Bridge token is not set correctly");
        assertEq(address(SourceOFTAdapter(srcUSDTBridgeProxy).endpoint()), srcLzEndpoint, "Source USDT Bridge LZ endpoint is not set correctly");
        bytes32 proxyAdminBytes = vm.load(srcUSDTBridgeProxy, ERC1967Utils.ADMIN_SLOT);
        address srcUSDTBridgeProxyAdmin = address(uint160(uint256(proxyAdminBytes)));
        assertEq(ProxyAdmin(srcUSDTBridgeProxyAdmin).owner(), srcUSDTBridgeProxyAdminOwner, "Source USDT Bridge Proxy Admin is not set correctly");
    }

    function _assertDestBridgeProperties() internal view {
        assertEq(DestinationOUSDT(destUSDTBridgeProxy).owner(), destUSDTBridgeOwner, "Destination USDT Bridge owner is not set correctly");
        assertEq(address(DestinationOUSDT(destUSDTBridgeProxy).token()), address(destUSDT), "Destination USDT Bridge token is not set correctly");
        assertEq(address(DestinationOUSDT(destUSDTBridgeProxy).endpoint()), destLzEndpoint, "Destination USDT Bridge LZ endpoint is not set correctly");
        bytes32 proxyAdminBytes = vm.load(destUSDTBridgeProxy, ERC1967Utils.ADMIN_SLOT);
        address destUSDTBridgeProxyAdmin = address(uint160(uint256(proxyAdminBytes)));
        assertEq(ProxyAdmin(destUSDTBridgeProxyAdmin).owner(), destUSDTBridgeProxyAdminOwner, "Destination USDT Bridge Proxy Admin is not set correctly");
    }

    function _assertSrcLZProperties() internal view {
        assertEq(ILayerZeroEndpointV2(srcLzEndpoint).getSendLibrary(address(srcUSDTBridgeProxy), destEID), srcLzSendUlnLib, "Source USDT Bridge LZ send library is not set correctly");
        (address receiveLib, ) = ILayerZeroEndpointV2(srcLzEndpoint).getReceiveLibrary(address(srcUSDTBridgeProxy), destEID);
        assertEq(receiveLib, srcLzRecvUlnLib, "Source USDT Bridge LZ receive library is not set correctly");

        UlnConfig memory defaultSendConfig = abi.decode(ILayerZeroEndpointV2(srcLzEndpoint).getConfig(address(0), srcLzSendUlnLib, destEID, ULN_CONFIG_TYPE), (UlnConfig));
        UlnConfig memory defaultRecvConfig = abi.decode(ILayerZeroEndpointV2(srcLzEndpoint).getConfig(address(0), srcLzRecvUlnLib, destEID, ULN_CONFIG_TYPE), (UlnConfig));

        assertEq(keccak256(ILayerZeroEndpointV2(srcLzEndpoint).getConfig(address(srcUSDTBridgeProxy), srcLzSendUlnLib, destEID, ULN_CONFIG_TYPE)), keccak256(abi.encode(_processUlnConfig(srcLzSendUlnConfig, defaultSendConfig))), "Source USDT Bridge LZ send ULN config is not set correctly");
        assertEq(keccak256(ILayerZeroEndpointV2(srcLzEndpoint).getConfig(address(srcUSDTBridgeProxy), srcLzRecvUlnLib, destEID, ULN_CONFIG_TYPE)), keccak256(abi.encode(_processUlnConfig(srcLzRecvUlnConfig, defaultRecvConfig))), "Source USDT Bridge LZ receive ULN config is not set correctly");
        assertEq(SourceOFTAdapter(srcUSDTBridgeProxy).enforcedOptions(destEID, SEND), OptionsBuilder.newOptions().addExecutorLzReceiveOption(srcLzReceiveGas, 0), "Enforced options should be set correctly");
    }

    function _assertDestLZProperties() internal view {
        assertEq(ILayerZeroEndpointV2(destLzEndpoint).getSendLibrary(address(destUSDTBridgeProxy), srcEID), destLzSendUlnLib, "Destination USDT Bridge LZ send library is not set correctly");
        (address receiveLib, ) = ILayerZeroEndpointV2(destLzEndpoint).getReceiveLibrary(address(destUSDTBridgeProxy), srcEID);
        assertEq(receiveLib, destLzRecvUlnLib, "Destination USDT Bridge LZ receive library is not set correctly");

        UlnConfig memory defaultSendConfig = abi.decode(ILayerZeroEndpointV2(destLzEndpoint).getConfig(address(0), destLzSendUlnLib, srcEID, ULN_CONFIG_TYPE), (UlnConfig));
        UlnConfig memory defaultRecvConfig = abi.decode(ILayerZeroEndpointV2(destLzEndpoint).getConfig(address(0), destLzRecvUlnLib, srcEID, ULN_CONFIG_TYPE), (UlnConfig));

        assertEq(keccak256(ILayerZeroEndpointV2(destLzEndpoint).getConfig(address(destUSDTBridgeProxy), destLzSendUlnLib, srcEID, ULN_CONFIG_TYPE)), keccak256(abi.encode(_processUlnConfig(destLzSendUlnConfig, defaultSendConfig))), "Destination USDT Bridge LZ send ULN config is not set correctly");
        assertEq(keccak256(ILayerZeroEndpointV2(destLzEndpoint).getConfig(address(destUSDTBridgeProxy), destLzRecvUlnLib, srcEID, ULN_CONFIG_TYPE)), keccak256(abi.encode(_processUlnConfig(destLzRecvUlnConfig, defaultRecvConfig))), "Destination USDT Bridge LZ receive ULN config is not set correctly");
        assertEq(DestinationOUSDT(destUSDTBridgeProxy).enforcedOptions(srcEID, SEND), OptionsBuilder.newOptions().addExecutorLzReceiveOption(destLzReceiveGas, 0), "Enforced options should be set correctly");
    }

    function _processUlnConfig(UlnConfig memory config, UlnConfig memory defaultConfig) internal pure returns (UlnConfig memory) {
        // 0 indicates default
        if (config.confirmations == DEFAULT) {
            config.confirmations = defaultConfig.confirmations;
        }
        if (config.requiredDVNCount == DEFAULT) {
            config.requiredDVNCount = defaultConfig.requiredDVNCount;
        }
        if (config.optionalDVNCount == DEFAULT) {
            config.optionalDVNCount = defaultConfig.optionalDVNCount;
        }

        // DEFAULT values cannot be NIL by `setDefaultUlnConfigs` of `UlnBase.sol` so it is safe to assume the above part did not set them to NIL
        // NIL indicates 0
        if (config.confirmations == NIL_CONFIRMATIONS) {
            config.confirmations = 0;
        }
        if (config.requiredDVNCount == NIL_DVN_COUNT) {
            config.requiredDVNCount = 0;
        }
        if (config.optionalDVNCount == NIL_DVN_COUNT) {
            config.optionalDVNCount = 0;
        }

        return config;
    }
}