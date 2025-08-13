// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {USDCBridgeDeploy, FiatTokenV2_2} from "../../../script/bridge_deploy/USDCBridgeDeploy.s.sol";
import {SourceOFTAdapter} from "../../../src/SourceOFTAdapter.sol";
import {DestinationOUSDC} from "../../../src/DestinationOUSDC.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract USDCBridgeDeployTestBase is Test {
    USDCBridgeDeploy public usdcBridgeDeploy;
    SourceOFTAdapter public ethUSDCBridge;
    DestinationOUSDC public citreaUSDCBridge;

    uint256 public ethForkId;
    uint256 public citreaForkId;

    address public mockEthUSDCBridgeOwner;
    address public mockEthUSDCBridgeProxyAdminOwner;
    address public mockCitreaUSDCBridgeOwner;
    address public mockCitreaUSDCBridgeProxyAdminOwner;

    string public constant ETH_RPC = "https://sepolia.drpc.org";
    address public constant ETH_USDC = 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238;
    address public constant ETH_LZ_ENDPOINT = 0x6EDCE65403992e310A62460808c4b910D972f10f;
    uint32 public constant ETH_EID = 40161;
    
    string public constant CITREA_RPC = "https://rpc.testnet.citrea.xyz";
    address public constant CITREA_USDC = 0x06811Ab270e94c7A4E114b972b8f7B8c4dD031EA;
    address public constant CITREA_MM = 0x15666fCded1bAC2366847e682Be79c12457ad36B;
    address public constant CITREA_LZ_ENDPOINT = 0x6C7Ab2202C98C4227C5c46f1417D81144DA716Ff;
    uint32 public constant CITREA_EID = 40344;

    function setUp() public virtual {
        usdcBridgeDeploy = new USDCBridgeDeploy();

        mockEthUSDCBridgeProxyAdminOwner = makeAddr("Eth USDC Bridge Proxy Admin Owner");
        mockEthUSDCBridgeOwner = makeAddr("Eth USDC Bridge Owner");

        ethForkId = vm.createSelectFork(ETH_RPC);
        ethUSDCBridge = SourceOFTAdapter(usdcBridgeDeploy._runEth(false, ETH_USDC, ETH_LZ_ENDPOINT, mockEthUSDCBridgeProxyAdminOwner, mockEthUSDCBridgeOwner));

        mockCitreaUSDCBridgeProxyAdminOwner = makeAddr("Citrea USDC Bridge Proxy Admin Owner");
        mockCitreaUSDCBridgeOwner = makeAddr("Citrea USDC Bridge Owner");

        citreaForkId = vm.createSelectFork(CITREA_RPC);
        citreaUSDCBridge = DestinationOUSDC(usdcBridgeDeploy._runCitrea(false, FiatTokenV2_2(CITREA_USDC), CITREA_LZ_ENDPOINT, mockCitreaUSDCBridgeProxyAdminOwner, mockCitreaUSDCBridgeOwner));
    }
}