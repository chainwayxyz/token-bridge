// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfigSetup} from "../ConfigSetup.s.sol";
import {IMessageLibManager} from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/IMessageLibManager.sol";
import "forge-std/console.sol";

contract PauseCalldataSrcBridges is ConfigSetup {
    address constant BLOCKED_MSG_LIB = 0x1ccBf0db9C192d969de57E25B3fF09A25bb1D862;

    function setUp() public virtual {
        loadUSDCConfig({isBridgeDeployed: true});
        loadUSDTConfig({isUSDTDeployed: true, isBridgeDeployed: true});
        loadWBTCConfig({isBridgeDeployed: true});
    }

    function run() public view {
        console.log("=== Pause Src Bridges (Ethereum) - Safe Batch Calldata ===");
        console.log("BlockedMsgLib:", BLOCKED_MSG_LIB);
        console.log("Peer EID (Citrea):", destEID);
        console.log("");

        _logBridgeCalldata("USDC", srcUSDCBridgeProxy, 1);
        _logBridgeCalldata("USDT", srcUSDTBridgeProxy, 3);
        _logBridgeCalldata("WBTC", srcWBTCBridge, 5);
    }

    function _logBridgeCalldata(string memory name, address bridge, uint256 txIndex) internal view {
        console.log("--- %s bridge: %s ---", name, bridge);

        console.log("[%s] setSendLibrary:", txIndex);
        console.log("  to:", srcLzEndpoint);
        console.log("  data:");
        console.logBytes(abi.encodeCall(IMessageLibManager.setSendLibrary, (bridge, destEID, BLOCKED_MSG_LIB)));

        console.log("[%s] setReceiveLibrary:", txIndex + 1);
        console.log("  to:", srcLzEndpoint);
        console.log("  data:");
        console.logBytes(abi.encodeCall(IMessageLibManager.setReceiveLibrary, (bridge, destEID, BLOCKED_MSG_LIB, 0)));

        console.log("");
    }
}
