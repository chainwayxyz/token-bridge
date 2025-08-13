// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import { FiatTokenV2_2 } from "../../../src/interfaces/IFiatTokenV2_2.sol";
import {USDCTransferOwner} from "../../../script/for_circle_takeover/USDCTransferOwner.s.sol";

contract USDCTransferOwnerTestBase is USDCTransferOwner, Test {
    FiatTokenV2_2 public constant DEST_USDC = FiatTokenV2_2(0x06811Ab270e94c7A4E114b972b8f7B8c4dD031EA);
    string public constant DEST_RPC = "https://rpc.testnet.citrea.xyz";
    uint256 public destForkId;
    address public usdcRolesHolder;

    function setUp() public virtual override {
        destForkId = vm.createSelectFork(DEST_RPC);
        address currentOwner = FiatTokenV2_2(DEST_USDC).owner();
        vm.startPrank(currentOwner);
        address usdcRolesHolderOwner = makeAddr("USDC_ROLES_HOLDER_OWNER");
        usdcRolesHolder = _run_(false, usdcRolesHolderOwner, address(DEST_USDC));
        vm.stopPrank();
    }
}