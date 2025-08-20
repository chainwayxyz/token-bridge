// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {USDCBridgeDeployTestBase, FiatTokenV2_2} from "../../deploy/base/USDCBridgeDeployBase.t.sol";
import {USDCSrcBridgePrepareTakeover, ERC1967Utils, SourceOFTAdapter} from "../../../../script/usdc/for_circle_takeover/01_USDCSrcBridgePrepareTakeover.s.sol";

contract USDCSrcBridgePrepareTakeoverTestBase is USDCBridgeDeployTestBase, USDCSrcBridgePrepareTakeover {
    function setUp() public virtual override(USDCBridgeDeployTestBase, USDCSrcBridgePrepareTakeover) {
        USDCBridgeDeployTestBase.setUp();
        vm.startPrank(mockSrcUSDCBridgeProxyAdminOwner);
        vm.selectFork(srcForkId);
        _run(false, SRC_LZ_ENDPOINT, SRC_USDC, address(srcUSDCBridge));
    }
}