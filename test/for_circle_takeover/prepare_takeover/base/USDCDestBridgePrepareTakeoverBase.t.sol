// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../../bridge_deploy/base/USDCBridgeDeployBase.t.sol";
import {USDCDestBridgePrepareTakeover, ERC1967Utils} from "../../../../script/for_circle_takeover/prepare_takeover/USDCDestBridgePrepareTakeover.s.sol";

contract USDCDestBridgePrepareTakeoverTestBase is USDCBridgeDeployTestBase, USDCDestBridgePrepareTakeover {
    function setUp() public virtual override(USDCBridgeDeployTestBase, USDCDestBridgePrepareTakeover) {
        USDCBridgeDeployTestBase.setUp();
        vm.startPrank(mockDestUSDCBridgeProxyAdminOwner);
        vm.selectFork(destForkId);
        _run(false, DEST_LZ_ENDPOINT, DEST_USDC, address(destUSDCBridge));
    }
}