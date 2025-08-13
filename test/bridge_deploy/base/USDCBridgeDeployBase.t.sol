// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {USDCBridgeDeploy, FiatTokenV2_2} from "../../../script/bridge_deploy/USDCBridgeDeploy.s.sol";
import {SourceOFTAdapter} from "../../../src/SourceOFTAdapter.sol";
import {DestinationOUSDC} from "../../../src/DestinationOUSDC.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract USDCBridgeDeployTestBase is Test {
    USDCBridgeDeploy public usdcBridgeDeploy;
    SourceOFTAdapter public srcUSDCBridge;
    DestinationOUSDC public destUSDCBridge;

    uint256 public srcForkId;
    uint256 public destForkId;

    address public mockSrcUSDCBridgeOwner;
    address public mockSrcUSDCBridgeProxyAdminOwner;
    address public mockDestUSDCBridgeOwner;
    address public mockDestUSDCBridgeProxyAdminOwner;

    string public constant SRC_RPC = "https://sepolia.drpc.org";
    address public constant SRC_USDC = 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238;
    address public constant SRC_LZ_ENDPOINT = 0x6EDCE65403992e310A62460808c4b910D972f10f;
    uint32 public constant SRC_EID = 40161;
    
    string public constant DEST_RPC = "https://rpc.testnet.citrea.xyz";
    address public constant DEST_USDC = 0x06811Ab270e94c7A4E114b972b8f7B8c4dD031EA;
    address public constant DEST_MM = 0x15666fCded1bAC2366847e682Be79c12457ad36B;
    address public constant DEST_LZ_ENDPOINT = 0x6C7Ab2202C98C4227C5c46f1417D81144DA716Ff;
    uint32 public constant DEST_EID = 40344;

    function setUp() public virtual {
        usdcBridgeDeploy = new USDCBridgeDeploy();

        mockSrcUSDCBridgeProxyAdminOwner = makeAddr("Src USDC Bridge Proxy Admin Owner");
        mockSrcUSDCBridgeOwner = makeAddr("Src USDC Bridge Owner");

        srcForkId = vm.createSelectFork(SRC_RPC);
        srcUSDCBridge = SourceOFTAdapter(usdcBridgeDeploy._runSrc(false, SRC_USDC, SRC_LZ_ENDPOINT, mockSrcUSDCBridgeProxyAdminOwner, mockSrcUSDCBridgeOwner));

        mockDestUSDCBridgeProxyAdminOwner = makeAddr("Dest USDC Bridge Proxy Admin Owner");
        mockDestUSDCBridgeOwner = makeAddr("Dest USDC Bridge Owner");

        destForkId = vm.createSelectFork(DEST_RPC);
        destUSDCBridge = DestinationOUSDC(usdcBridgeDeploy._runDest(false, FiatTokenV2_2(DEST_USDC), DEST_LZ_ENDPOINT, mockDestUSDCBridgeProxyAdminOwner, mockDestUSDCBridgeOwner));
    }
}