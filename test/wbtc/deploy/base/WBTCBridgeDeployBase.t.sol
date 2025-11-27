// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {WBTCSrcBridgeDeploy} from "../../../../script/wbtc/deploy/01_WBTCSrcBridgeDeploy.s.sol";
import {WBTCDestBridgeDeploy} from "../../../../script/wbtc/deploy/02_WBTCDestBridgeDeploy.s.sol";
import {WBTCOFTAdapter} from "../../../../src/wbtc/WBTCOFTAdapter.sol";
import {WBTCOFT} from "../../../../src/wbtc/WBTCOFT.sol"; 

contract WBTCBridgeDeployTestBase is Test {
    WBTCOFTAdapter public srcWBTCBridge_;
    WBTCOFT public destWBTCBridge_;

    uint256 public srcForkId;
    uint256 public destForkId;

    string public constant SRC_RPC = "https://sepolia.drpc.org";
    address public constant SRC_WBTC = 0x92f3B59a79bFf5dc60c0d59eA13a44D082B2bdFC;
    address public constant SRC_LZ_ENDPOINT = 0x6EDCE65403992e310A62460808c4b910D972f10f;
    uint32 public constant SRC_EID = 40161;

    string public constant DEST_RPC = "https://rpc.testnet.citrea.xyz";
    address public constant DEST_LZ_ENDPOINT = 0x6C7Ab2202C98C4227C5c46f1417D81144DA716Ff;
    uint32 public constant DEST_EID = 40344;

    address deployer;

    function setUp() public virtual {
        srcForkId = vm.createSelectFork(SRC_RPC);

        WBTCSrcBridgeDeploy wbtcSrcBridgeDeploy = new WBTCSrcBridgeDeploy();
        deployer = address(wbtcSrcBridgeDeploy);
        srcWBTCBridge_ = WBTCOFTAdapter(wbtcSrcBridgeDeploy._run(false, SRC_WBTC, SRC_LZ_ENDPOINT, deployer));

        destForkId = vm.createSelectFork(DEST_RPC);
        
        WBTCDestBridgeDeploy wbtcDestBridgeDeploy = new WBTCDestBridgeDeploy();

        string memory wbtcName = "Bridged WBTC (Dest)";
        string memory wbtcSymbol = "WBTC.e";
        destWBTCBridge_ = WBTCOFT(wbtcDestBridgeDeploy._run(false, wbtcName, wbtcSymbol, DEST_LZ_ENDPOINT, deployer));
    }
}
