// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {ConfigSetup} from "../../../script/ConfigSetup.s.sol";
import {FiatTokenV2_2} from "../../../src/interfaces/IFiatTokenV2_2.sol";
import {MasterMinter} from "../../../src/interfaces/IMasterMinter.sol";
import {DestinationOUSDC} from "../../../src/DestinationOUSDC.sol";
import {SourceOFTAdapter} from "../../../src/SourceOFTAdapter.sol";
import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import {ERC1967Utils} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol";
import {OptionsBuilder} from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OptionsBuilder.sol";
import {ILayerZeroEndpointV2} from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";
import {UlnConfig} from "@layerzerolabs/lz-evm-messagelib-v2/contracts/uln/UlnBase.sol";

contract USDCPostDeploymentTest is ConfigSetup, Test {
    using OptionsBuilder for bytes;

    uint8 public constant DEFAULT = 0;
    uint8 public constant NIL_DVN_COUNT = type(uint8).max;
    uint64 public constant NIL_CONFIRMATIONS = type(uint64).max;
    bytes32 public constant USDC_PROXY_ADMIN_SLOT = 0x10d6a54a4754c8869d6886b5f5d7fbfa5b4522237ea5c60d11bc4e7a1ff9390b;

    function setUp() public {
        if (!vm.envOr("IS_POST_DEPLOYMENT", false)) {
            return;
        }

        ConfigSetup.loadUSDCConfig(true);
    }

    function testPostDeployment() public {
        if (!vm.envOr("IS_POST_DEPLOYMENT", false)) {
            vm.skip(true);
        }

        vm.createSelectFork(srcRPC);

        _assertSrcBridgeProperties();
        _assertSrcLZProperties();

        vm.createSelectFork(destRPC);

        _assertUSDCProperties();
        _assertDestBridgeProperties();
        _assertDestLZProperties();
    }

    function _assertUSDCProperties() internal {
        FiatTokenV2_2 usdc = FiatTokenV2_2(destUSDC);
        assertEq(usdc.owner(), destUSDCOwner, "Destination USDC owner is not set correctly");
        assertEq(usdc.pauser(), destUSDCOwner, "Destination USDC pauser is not set correctly");
        assertEq(usdc.blacklister(), destUSDCOwner, "Destination USDC blacklister is not set correctly");
        assertEq(usdc.name(), destUSDCName, "Destination USDC name is not set correctly");
        assertEq(usdc.symbol(), destUSDCSymbol, "Destination USDC symbol is not set correctly");
        assertEq(usdc.decimals(), 6, "Destination USDC decimals should be 6");
        address proxyAdminAddress = address(uint160(uint256(vm.load(address(usdc), USDC_PROXY_ADMIN_SLOT))));
        assertEq(proxyAdminAddress, destUSDCProxyAdmin, "Destination USDC proxy admin is not set correctly");
        assertEq(usdc.masterMinter(), destMM, "Destination USDC MasterMinter is not set correctly");
        assertEq(MasterMinter(destMM).owner(), destMMOwner, "Destination USDC MasterMinter owner is not set correctly");
        _assertUSDCBlacklistAbility(usdc);
    }

    function _assertUSDCBlacklistAbility(FiatTokenV2_2 usdc) internal {
        address userToBlacklist = makeAddr("userToBlacklist");
        uint256 initialBalance = 1000 * (10 ** usdc.decimals());
        deal(address(usdc), userToBlacklist, initialBalance);
        assertEq(usdc.balanceOf(userToBlacklist), initialBalance, "User should have initial balance");

        vm.prank(userToBlacklist);
        // Verify user can transfer tokens before being blacklisted
        usdc.transfer(address(1), 1);

        vm.prank(destUSDCOwner);
        usdc.blacklist(userToBlacklist);
        assertTrue(usdc.isBlacklisted(userToBlacklist), "User should be blacklisted");

        vm.startPrank(userToBlacklist);
        vm.expectRevert("Blacklistable: account is blacklisted");
        usdc.transfer(address(1), 1);
        vm.expectRevert("Blacklistable: account is blacklisted");
        usdc.transferFrom(userToBlacklist, address(1), 1);
        vm.stopPrank();
    }

    function _assertSrcBridgeProperties() internal view {
        assertEq(SourceOFTAdapter(srcUSDCBridgeProxy).owner(), srcUSDCBridgeOwner, "Source USDC Bridge owner is not set correctly");
        assertEq(address(SourceOFTAdapter(srcUSDCBridgeProxy).token()), address(srcUSDC), "Source USDC Bridge token is not set correctly");
        assertEq(address(SourceOFTAdapter(srcUSDCBridgeProxy).endpoint()), srcLzEndpoint, "Source USDC Bridge LZ endpoint is not set correctly");
        bytes32 proxyAdminBytes = vm.load(srcUSDCBridgeProxy, ERC1967Utils.ADMIN_SLOT);
        address srcUSDCBridgeProxyAdmin = address(uint160(uint256(proxyAdminBytes)));
        assertEq(ProxyAdmin(srcUSDCBridgeProxyAdmin).owner(), srcUSDCBridgeProxyAdminOwner, "Source USDC Bridge Proxy Admin is not set correctly");
    }

    function _assertDestBridgeProperties() internal view {
        assertEq(DestinationOUSDC(destUSDCBridgeProxy).owner(), destUSDCBridgeOwner, "Destination USDC Bridge owner is not set correctly");
        assertEq(address(DestinationOUSDC(destUSDCBridgeProxy).token()), address(destUSDC), "Destination USDC Bridge token is not set correctly");
        assertEq(address(DestinationOUSDC(destUSDCBridgeProxy).endpoint()), destLzEndpoint, "Destination USDC Bridge LZ endpoint is not set correctly");
        bytes32 proxyAdminBytes = vm.load(destUSDCBridgeProxy, ERC1967Utils.ADMIN_SLOT);
        address destUSDCBridgeProxyAdmin = address(uint160(uint256(proxyAdminBytes)));
        assertEq(ProxyAdmin(destUSDCBridgeProxyAdmin).owner(), destUSDCBridgeProxyAdminOwner, "Destination USDC Bridge Proxy Admin is not set correctly");
    }

    function _assertSrcLZProperties() internal view {
        assertEq(ILayerZeroEndpointV2(srcLzEndpoint).getSendLibrary(address(srcUSDCBridgeProxy), destEID), srcLzSendUlnLib, "Source USDC Bridge LZ send library is not set correctly");
        (address receiveLib, ) = ILayerZeroEndpointV2(srcLzEndpoint).getReceiveLibrary(address(srcUSDCBridgeProxy), destEID);
        assertEq(receiveLib, srcLzRecvUlnLib, "Source USDC Bridge LZ receive library is not set correctly");

        UlnConfig memory defaultSendConfig = abi.decode(ILayerZeroEndpointV2(srcLzEndpoint).getConfig(address(0), srcLzSendUlnLib, destEID, ULN_CONFIG_TYPE), (UlnConfig));
        UlnConfig memory defaultRecvConfig = abi.decode(ILayerZeroEndpointV2(srcLzEndpoint).getConfig(address(0), srcLzRecvUlnLib, destEID, ULN_CONFIG_TYPE), (UlnConfig));

        assertEq(keccak256(ILayerZeroEndpointV2(srcLzEndpoint).getConfig(address(srcUSDCBridgeProxy), srcLzSendUlnLib, destEID, ULN_CONFIG_TYPE)), keccak256(abi.encode(_processUlnConfig(srcLzSendUlnConfig, defaultSendConfig))), "Source USDC Bridge LZ send ULN config is not set correctly");
        assertEq(keccak256(ILayerZeroEndpointV2(srcLzEndpoint).getConfig(address(srcUSDCBridgeProxy), srcLzRecvUlnLib, destEID, ULN_CONFIG_TYPE)), keccak256(abi.encode(_processUlnConfig(srcLzRecvUlnConfig, defaultRecvConfig))), "Source USDC Bridge LZ receive ULN config is not set correctly");
        assertEq(SourceOFTAdapter(srcUSDCBridgeProxy).enforcedOptions(destEID, SEND), OptionsBuilder.newOptions().addExecutorLzReceiveOption(srcLzReceiveGas, 0), "Enforced options should be set correctly");
    }

    function _assertDestLZProperties() internal view {
        assertEq(ILayerZeroEndpointV2(destLzEndpoint).getSendLibrary(address(destUSDCBridgeProxy), srcEID), destLzSendUlnLib, "Destination USDC Bridge LZ send library is not set correctly");
        (address receiveLib, ) = ILayerZeroEndpointV2(destLzEndpoint).getReceiveLibrary(address(destUSDCBridgeProxy), srcEID);
        assertEq(receiveLib, destLzRecvUlnLib, "Destination USDC Bridge LZ receive library is not set correctly");

        UlnConfig memory defaultSendConfig = abi.decode(ILayerZeroEndpointV2(destLzEndpoint).getConfig(address(0), destLzSendUlnLib, srcEID, ULN_CONFIG_TYPE), (UlnConfig));
        UlnConfig memory defaultRecvConfig = abi.decode(ILayerZeroEndpointV2(destLzEndpoint).getConfig(address(0), destLzRecvUlnLib, srcEID, ULN_CONFIG_TYPE), (UlnConfig));

        assertEq(keccak256(ILayerZeroEndpointV2(destLzEndpoint).getConfig(address(destUSDCBridgeProxy), destLzSendUlnLib, srcEID, ULN_CONFIG_TYPE)), keccak256(abi.encode(_processUlnConfig(destLzSendUlnConfig, defaultSendConfig))), "Destination USDC Bridge LZ send ULN config is not set correctly");
        assertEq(keccak256(ILayerZeroEndpointV2(destLzEndpoint).getConfig(address(destUSDCBridgeProxy), destLzRecvUlnLib, srcEID, ULN_CONFIG_TYPE)), keccak256(abi.encode(_processUlnConfig(destLzRecvUlnConfig, defaultRecvConfig))), "Destination USDC Bridge LZ receive ULN config is not set correctly");
        assertEq(DestinationOUSDC(destUSDCBridgeProxy).enforcedOptions(srcEID, SEND), OptionsBuilder.newOptions().addExecutorLzReceiveOption(destLzReceiveGas, 0), "Enforced options should be set correctly");
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