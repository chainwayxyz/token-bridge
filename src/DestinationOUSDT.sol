// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import { OFTCoreUpgradeable } from "@layerzerolabs/oft-evm-upgradeable/contracts/oft/OFTCoreUpgradeable.sol";
import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import { IERC7802 } from "./usdt0/Wrappers/interfaces/IERC7802.sol";

interface IOFTToken is IERC20Metadata, IERC7802 {

}

contract DestinationOUSDT is OFTCoreUpgradeable {
    IOFTToken internal immutable token_;

    function token() external view returns (address) {
        return address(token_);
    }

    constructor(
        address _lzEndpoint,
        IOFTToken _token
    ) OFTCoreUpgradeable(_token.decimals(), _lzEndpoint) {
        token_ = _token;
        _disableInitializers();
    }

    function initialize(address _delegate) public initializer {
        __OFTCore_init(_delegate);
        __Ownable_init(_delegate);
    }

    /**
     * @notice Indicates whether the OFT contract requires approval of the 'token()' to send.
     * @return requiresApproval Needs approval of the underlying token implementation.
     *
     * @dev In the case of OFT where the contract IS the token, approval is NOT required.
     */
    function approvalRequired() external pure virtual returns (bool) {
        return false;
    }

    /**
     * @dev Burns tokens from the sender's specified balance.
     * @param _from The address to debit the tokens from.
     * @param _amountLD The amount of tokens to send in local decimals.
     * @param _minAmountLD The minimum amount to send in local decimals.
     * @param _dstEid The destination chain ID.
     * @return amountSentLD The amount sent in local decimals.
     * @return amountReceivedLD The amount received in local decimals on the remote.
     */
    function _debit(
        address _from,
        uint256 _amountLD,
        uint256 _minAmountLD,
        uint32 _dstEid
    ) internal virtual override returns (uint256 amountSentLD, uint256 amountReceivedLD) {
        (amountSentLD, amountReceivedLD) = _debitView(_amountLD, _minAmountLD, _dstEid);

        // @dev Default OFT burns on src.
        token_.crosschainBurn(_from, amountSentLD);
    }

    /**
     * @dev Credits tokens to the specified address.
     * @param _to The address to credit the tokens to.
     * @param _amountLD The amount of tokens to credit in local decimals.
     * @dev _srcEid The source chain ID.
     * @return amountReceivedLD The amount of tokens ACTUALLY received in local decimals.
     */
    function _credit(
        address _to,
        uint256 _amountLD,
        uint32 /*_srcEid*/
    ) internal virtual override returns (uint256 amountReceivedLD) {
        if (_to == address(0x0)) _to = address(0xdead); // _mint(...) does not support address(0x0)
        // @dev Default OFT mints on dst.
        token_.crosschainMint(_to, _amountLD);
        return _amountLD;
    }
}
