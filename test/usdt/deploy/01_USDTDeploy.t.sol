// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "./base/USDTDeployBase.t.sol";

contract USDTDeployTest is USDTDeployTestBase {
    function testName() public view {
        assertEq(usdt.name(),  "Bridged USDT (Dest)", "USDT name should match");
    }

    function testSymbol() public view {
        assertEq(usdt.symbol(), "USDT.s", "USDT symbol should match");
    }

    function testDecimals() public view {
        assertEq(usdt.decimals(), 6, "USDT decimals should be 6");
    }

    function testOwner() public view {
        assertEq(usdt.owner(), deployer, "Owner should be set to deployer initially");
    }

    function testProxyAdminOwner() public view {
        address proxyAdmin = address(uint160(uint256(vm.load(address(usdt), ERC1967Utils.ADMIN_SLOT))));
        assertEq(ProxyAdmin(proxyAdmin).owner(), usdtProxyAdminOwner, "Proxy Admin Owner should be set correctly");
    }
}