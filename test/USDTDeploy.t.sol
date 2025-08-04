// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {USDTDeploy} from "../script/USDTDeploy.s.sol";
import {TetherTokenOFTExtension} from "../src/interfaces/IOFTExtension.sol";

contract USDTDeployTest is Test {
    USDTDeploy public usdtDeploy;
    TetherTokenOFTExtension public usdt;

    function setUp() public {
        usdtDeploy = new USDTDeploy();
        usdtDeploy.setUp();
        usdt = TetherTokenOFTExtension(usdtDeploy._run(false));
    }

    function testName() public view {
        assertEq(usdt.name(),  "Bridged USDT (Citrea)", "USDT name should match");
    }

    function testSymbol() public view {
        assertEq(usdt.symbol(), "USDT.e", "USDT symbol should match");
    }

    function testDecimals() public view {
        assertEq(usdt.decimals(), 6, "USDT decimals should be 6");
    }

    function testOwner() public view {
        assertEq(usdt.owner(), usdtDeploy.citreaUSDTOwner(), "Owner should be set correctly");
    }
}