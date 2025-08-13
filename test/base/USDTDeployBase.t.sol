// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {USDTDeploy} from "../../script/USDTDeploy.s.sol";
import {TetherTokenOFTExtension} from "../../src/interfaces/IOFTExtension.sol";
import {ERC1967Utils} from "openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Utils.sol";
import "openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";

contract USDTDeployTestBase is Test {
    USDTDeploy public usdtDeploy;
    TetherTokenOFTExtension public usdt;
    address public usdtOwner;
    address public usdtProxyAdminOwner;

    function setUp() public virtual {
        usdtDeploy = new USDTDeploy();
        usdtDeploy.setUp();

        usdtOwner = makeAddr("USDT Owner");
        usdtProxyAdminOwner = makeAddr("USDT Proxy Admin Owner");

        string memory usdtName = "Bridged USDT (Dest)";
        string memory usdtSymbol = "USDT.s";

        usdt = TetherTokenOFTExtension(usdtDeploy._run(false, usdtProxyAdminOwner, usdtOwner, usdtName, usdtSymbol));
    }
}