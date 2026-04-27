// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ConfigSetup} from "../ConfigSetup.s.sol";
import {IMessageLibManager} from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/IMessageLibManager.sol";
import "forge-std/console.sol";

contract PauseCalldataDestBridges is ConfigSetup {
    address constant BLOCKED_MSG_LIB = 0xC1cE56B2099cA68720592583C7984CAb4B6d7E7a;

    function setUp() public virtual {
        loadUSDCConfig({isBridgeDeployed: true});
        loadUSDTConfig({isUSDTDeployed: true, isBridgeDeployed: true});
        loadWBTCConfig({isBridgeDeployed: true});
    }

    function run() public view {
        console.log("=== Pause Dest Bridges (Citrea) - Safe Batch Calldata ===");
        console.log("BlockedMsgLib:", BLOCKED_MSG_LIB);
        console.log("Peer EID (Ethereum):", srcEID);
        console.log("");

        _logBridgeCalldata("USDC", destUSDCBridgeProxy, 1);
        _logBridgeCalldata("USDT", destUSDTBridgeProxy, 3);
        _logBridgeCalldata("WBTC", destWBTCBridge, 5);
    }

    function _logBridgeCalldata(string memory name, address bridge, uint256 txIndex) internal view {
        console.log("--- %s bridge: %s ---", name, bridge);

        console.log("[%s] setSendLibrary:", txIndex);
        console.log("  to:", destLzEndpoint);
        console.log("  data:");
        console.logBytes(abi.encodeCall(IMessageLibManager.setSendLibrary, (bridge, srcEID, BLOCKED_MSG_LIB)));

        console.log("[%s] setReceiveLibrary:", txIndex + 1);
        console.log("  to:", destLzEndpoint);
        console.log("  data:");
        console.logBytes(abi.encodeCall(IMessageLibManager.setReceiveLibrary, (bridge, srcEID, BLOCKED_MSG_LIB, 0)));

        console.log("");
    }
}
