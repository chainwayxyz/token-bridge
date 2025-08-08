// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../../bridge_deploy/base/USDCBridgeDeployBase.t.sol";
import {USDCSrcBridgePrepareTakeover, ERC1967Utils} from "../../../../script/for_circle_takeover/prepare_takeover/USDCSrcBridgePrepareTakeover.s.sol";

contract USDCSrcBridgePrepareTakeoverTestBase is USDCBridgeDeployTestBase, USDCSrcBridgePrepareTakeover {
    function setUp() public virtual override(USDCBridgeDeployTestBase, USDCSrcBridgePrepareTakeover) {
        USDCBridgeDeployTestBase.setUp();
        vm.startPrank(mockEthUSDCBridgeProxyAdminOwner);
        vm.selectFork(ethForkId);
        _run(false, ETH_LZ_ENDPOINT, ETH_USDC, address(ethUSDCBridge));
    }
}