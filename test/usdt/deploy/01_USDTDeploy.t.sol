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

    function testBlacklist() public {
        address userToBlacklist = makeAddr("userToBlacklist");
        uint256 initialBalance = 1000 * (10 ** usdt.decimals());
        vm.prank(usdt.owner());
        usdt.mint(userToBlacklist, initialBalance);
        assertEq(usdt.balanceOf(userToBlacklist), initialBalance, "User should have initial balance");

        vm.prank(userToBlacklist);
        // Verify user can transfer tokens before being blacklisted
        usdt.transfer(address(1), 1);

        vm.prank(usdt.owner());
        usdt.addToBlockedList(userToBlacklist);
        assertTrue(usdt.isBlocked(userToBlacklist), "User should be blacklisted");

        vm.startPrank(userToBlacklist);
        vm.expectRevert("TetherToken: from is blocked");
        usdt.transfer(address(1), 1);
        vm.expectRevert("Blocked: msg.sender is blocked");
        usdt.transferFrom(userToBlacklist, address(1), 1);
        vm.stopPrank();

        vm.prank(usdt.owner());
        usdt.destroyBlockedFunds(userToBlacklist);
        assertEq(usdt.balanceOf(userToBlacklist), 0, "User balance should be 0 after destroying funds");
    }
}