// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {USDTBridgeDeploy} from "../../../script/bridge_deploy/USDTBridgeDeploy.s.sol";
import {USDTDeployTestBase} from "../../base/USDTDeployBase.t.sol";
import {SourceOFTAdapter} from "../../../src/SourceOFTAdapter.sol";
import {DestinationOUSDT} from "../../../src/DestinationOUSDT.sol";

contract USDTBridgeDeployTestBase is USDTDeployTestBase {
    USDTBridgeDeploy public usdtBridgeDeploy;
    SourceOFTAdapter public ethUSDTBridge;
    DestinationOUSDT public citreaUSDTBridge;

    uint256 public ethForkId;
    uint256 public citreaForkId;

    address public mockEthUSDTBridgeOwner;
    address public mockCitreaUSDTBridgeOwner;

    string public constant ETH_RPC = "https://sepolia.drpc.org";
    address public constant ETH_USDT = 0x7169D38820dfd117C3FA1f22a697dBA58d90BA06;
    address public constant ETH_LZ_ENDPOINT = 0x6EDCE65403992e310A62460808c4b910D972f10f;
    uint32 public constant ETH_EID = 40161;

    string public constant CITREA_RPC = "https://rpc.testnet.citrea.xyz";
    address public constant CITREA_LZ_ENDPOINT = 0x6C7Ab2202C98C4227C5c46f1417D81144DA716Ff;
    uint32 public constant CITREA_EID = 40344;

    function setUp() public virtual override {
        USDTDeployTestBase.setUp();

        usdtBridgeDeploy = new USDTBridgeDeploy();

        address ethUSDTBridgeProxyAdminOwner = makeAddr("Eth USDT Bridge Proxy Admin Owner");
        mockEthUSDTBridgeOwner = makeAddr("Eth USDT Bridge Owner");

        ethForkId = vm.createSelectFork(ETH_RPC);
        ethUSDTBridge = SourceOFTAdapter(usdtBridgeDeploy._runEth(false, ETH_USDT, ETH_LZ_ENDPOINT, ethUSDTBridgeProxyAdminOwner, mockEthUSDTBridgeOwner));

        address citreaUSDTBridgeProxyAdminOwner = makeAddr("Citrea USDT Bridge Proxy Admin Owner");
        mockCitreaUSDTBridgeOwner = makeAddr("Citrea USDT Bridge Owner");

        citreaForkId = vm.createSelectFork(CITREA_RPC);
        citreaUSDTBridge = DestinationOUSDT(usdtBridgeDeploy._runCitrea(false, address(usdt), CITREA_LZ_ENDPOINT, citreaUSDTBridgeProxyAdminOwner, mockCitreaUSDTBridgeOwner));
    }
}