// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/USDCRolesHolder.sol";
import { FiatTokenV2_2 } from "../src/interfaces/IFiatTokenV2_2.sol";

contract USDCTransferOwner is Script {
    address public citreaUSDC;
    string public citreaRPC;

    address public usdcRolesHolderOwner;

    function setUp() public {
        citreaUSDC = vm.envAddress("CITREA_USDC");
        citreaRPC = vm.envString("CITREA_RPC");
        usdcRolesHolderOwner = vm.envAddress("USDC_ROLES_HOLDER_OWNER");
    }

    function run() public {
        USDCRolesHolder usdcRolesHolder = new USDCRolesHolder(usdcRolesHolderOwner, citreaUSDC);
        FiatTokenV2_2(citreaUSDC).transferOwnership(address(usdcRolesHolder));
    }
}