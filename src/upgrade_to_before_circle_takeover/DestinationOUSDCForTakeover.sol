// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import {OFTCoreUpgradeable} from "@layerzerolabs/oft-evm-upgradeable/contracts/oft/OFTCoreUpgradeable.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {FiatTokenV2_2} from "./interfaces/IFiatTokenV2_2.sol";
import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";

contract DestinationOUSDC is OFTCoreUpgradeable, PausableUpgradeable {
    using SafeERC20 for IERC20;
    FiatTokenV2_2 internal immutable token_;

    function token() external view returns (address) {
        return address(token_);
    }

    constructor(address _lzEndpoint, FiatTokenV2_2 _token) OFTCoreUpgradeable(_token.decimals(), _lzEndpoint) {
        token_ = _token;
        _disableInitializers();
    }

    function initialize(address _delegate) public initializer {
        __OFTCore_init(_delegate);
        __Ownable_init(_delegate);
        __Pausable_init();
    }

    /**
     * @notice Indicates whether the OFT contract requires approval of the 'token()' to send.
     * @return requiresApproval Needs approval of the underlying token implementation.
     *
     * @dev In the case of OFT where the contract IS the token, approval is NOT required.
     */
    function approvalRequired() external pure virtual returns (bool) {
        return true;
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
    function _debit(address _from, uint256 _amountLD, uint256 _minAmountLD, uint32 _dstEid)
        internal
        virtual
        override
        whenNotPaused
        returns (uint256 amountSentLD, uint256 amountReceivedLD)
    {
        (amountSentLD, amountReceivedLD) = _debitView(_amountLD, _minAmountLD, _dstEid);

        // @dev Default OFT transfers and burns on src.
        IERC20(address(token_)).safeTransferFrom(_from, address(this), amountSentLD);
        token_.burn(amountSentLD);
    }

    /**
     * @dev Credits tokens to the specified address.
     * @param _to The address to credit the tokens to.
     * @param _amountLD The amount of tokens to credit in local decimals.
     * @dev _srcEid The source chain ID.
     * @return amountReceivedLD The amount of tokens ACTUALLY received in local decimals.
     */
    function _credit(address _to, uint256 _amountLD, uint32 /*_srcEid*/ )
        internal
        virtual
        override
        whenNotPaused
        returns (uint256 amountReceivedLD)
    {
        // @dev Default OFT mints on dst.
        token_.mint(_to, _amountLD);
        return _amountLD;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }
}
