// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {USDTSrcBridgeDeploy} from "../../../../script/usdt/deploy/02_USDTSrcBridgeDeploy.s.sol";
import {USDTDestBridgeDeploy} from "../../../../script/usdt/deploy/03_USDTDestBridgeDeploy.s.sol";
import {USDTDeployTestBase} from "./USDTDeployBase.t.sol";
import {SourceOFTAdapter} from "../../../../src/SourceOFTAdapter.sol";
import {DestinationOUSDT} from "../../../../src/DestinationOUSDT.sol";

contract USDTBridgeDeployTestBase is USDTDeployTestBase {
    SourceOFTAdapter public srcUSDTBridge;
    DestinationOUSDT public destUSDTBridge;

    uint256 public srcForkId;
    uint256 public destForkId;

    string public constant SRC_RPC = "https://sepolia.drpc.org";
    address public constant SRC_USDT = 0x7169D38820dfd117C3FA1f22a697dBA58d90BA06;
    address public constant SRC_LZ_ENDPOINT = 0x6EDCE65403992e310A62460808c4b910D972f10f;
    uint32 public constant SRC_EID = 40161;

    string public constant DEST_RPC = "https://rpc.testnet.citrea.xyz";
    address public constant DEST_LZ_ENDPOINT = 0x6C7Ab2202C98C4227C5c46f1417D81144DA716Ff;
    uint32 public constant DEST_EID = 40344;

    function setUp() public virtual override {
        USDTDeployTestBase.setUp();

        address srcUSDTBridgeProxyAdminOwner = makeAddr("Src USDT Bridge Proxy Admin Owner");

        srcForkId = vm.createSelectFork(SRC_RPC);
        USDTSrcBridgeDeploy usdtSrcBridgeDeploy = new USDTSrcBridgeDeploy();
        srcUSDTBridge = SourceOFTAdapter(usdtSrcBridgeDeploy._run(false, SRC_USDT, SRC_LZ_ENDPOINT, srcUSDTBridgeProxyAdminOwner, deployer));

        address destUSDTBridgeProxyAdminOwner = makeAddr("Dest USDT Bridge Proxy Admin Owner");

        destForkId = vm.createSelectFork(DEST_RPC);
        USDTDestBridgeDeploy usdtDestBridgeDeploy = new USDTDestBridgeDeploy();
        destUSDTBridge = DestinationOUSDT(usdtDestBridgeDeploy._run(false, address(usdt), DEST_LZ_ENDPOINT, destUSDTBridgeProxyAdminOwner, deployer));
    }
}