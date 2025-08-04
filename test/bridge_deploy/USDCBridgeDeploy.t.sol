// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {USDCBridgeDeploy} from "../../script/bridge_deploy/USDCBridgeDeploy.s.sol";
import {SourceOFTAdapter} from "../../src/SourceOFTAdapter.sol";
import {DestinationOUSDC} from "../../src/DestinationOUSDC.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract USDCBridgeDeployTest is Test {
    USDCBridgeDeploy public usdcBridgeDeploy;
    SourceOFTAdapter public ethUSDCBridge;
    DestinationOUSDC public citreaUSDCBridge;

    uint256 public ethForkId;
    uint256 public citreaForkId;

    function setUp() public virtual {
        usdcBridgeDeploy = new USDCBridgeDeploy();
        usdcBridgeDeploy.setUp();

        ethForkId = vm.createSelectFork(usdcBridgeDeploy.ethRPC());
        ethUSDCBridge = SourceOFTAdapter(usdcBridgeDeploy._runEth(false));

        citreaForkId = vm.createSelectFork(usdcBridgeDeploy.citreaRPC());
        citreaUSDCBridge = DestinationOUSDC(usdcBridgeDeploy._runCitrea(false));
    }

    function testOwner() public {
        vm.selectFork(ethForkId);
        assertEq(ethUSDCBridge.owner(), usdcBridgeDeploy.ethUSDCBridgeOwner(), "Owner should be set correctly");

        vm.selectFork(citreaForkId);
        assertEq(citreaUSDCBridge.owner(), usdcBridgeDeploy.citreaUSDCBridgeOwner(), "Owner should be set correctly");
    }

    function testCannotReinitialize() public {
        vm.selectFork(ethForkId);
        vm.expectRevert(Initializable.InvalidInitialization.selector);
        ethUSDCBridge.initialize(makeAddr("arbitrary"));

        vm.selectFork(citreaForkId);
        vm.expectRevert(Initializable.InvalidInitialization.selector);
        citreaUSDCBridge.initialize(makeAddr("arbitrary"));
    }
}