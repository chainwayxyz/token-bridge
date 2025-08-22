// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {DestinationOUSDT, IOFTToken} from "../../../src/DestinationOUSDT.sol";

contract DestinationOUSDTHarness is DestinationOUSDT {
    constructor(address _lzEndpoint, IOFTToken _token) DestinationOUSDT(_lzEndpoint, _token) {}

    function debit(address from, uint256 amountLD, uint256 minAmountLD, uint32 dstEid)
        external
        returns (uint256 amountSentLD, uint256 amountReceivedLD)
    {
        return _debit(from, amountLD, minAmountLD, dstEid);
    }

    function credit(address to, uint256 amountLD, uint32 srcEid) external returns (uint256 amountReceivedLD) {
        return _credit(to, amountLD, srcEid);
    }
}