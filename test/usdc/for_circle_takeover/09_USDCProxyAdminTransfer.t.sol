// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import { FiatTokenV2_2 } from "../../../src/interfaces/IFiatTokenV2_2.sol";
import {USDCProxyAdminTransfer} from "../../../script/usdc/for_circle_takeover/09_USDCProxyAdminTransfer.s.sol";

contract USDCProxyAdminTransferTest is USDCProxyAdminTransfer, Test {
    FiatTokenV2_2 public constant DEST_USDC = FiatTokenV2_2(0x06811Ab270e94c7A4E114b972b8f7B8c4dD031EA);
    string public constant DEST_RPC = "https://rpc.testnet.citrea.xyz";
    bytes32 public constant FIAT_TOKEN_PROXY_ADMIN_SLOT = 0x10d6a54a4754c8869d6886b5f5d7fbfa5b4522237ea5c60d11bc4e7a1ff9390b;

    function setUp() public override {}

    function testProxyAdminTransfer() public {
        vm.createSelectFork(DEST_RPC);
        address currentProxyAdmin = address(uint160(uint256(vm.load(address(DEST_USDC), FIAT_TOKEN_PROXY_ADMIN_SLOT))));
        vm.startPrank(currentProxyAdmin);
        address circleProxyAdmin = makeAddr("CIRCLE_USDC_PROXY_ADMIN");
        _run(false, address(DEST_USDC), circleProxyAdmin);
        address newProxyAdmin = address(uint160(uint256(vm.load(address(DEST_USDC), FIAT_TOKEN_PROXY_ADMIN_SLOT))));
        assertEq(newProxyAdmin, circleProxyAdmin, "Proxy admin should be transferred to Circle's address");
    }
}