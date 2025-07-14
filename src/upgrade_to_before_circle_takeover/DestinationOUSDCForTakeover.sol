// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {OFTAdapterUpgradeable} from "@layerzerolabs/oft-evm-upgradeable/contracts/oft/OFTAdapterUpgradeable.sol";
import {FiatTokenV2_2} from "../interfaces/IFiatTokenV2_2.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";

contract DestinationOUSDC is OFTAdapterUpgradeable, PausableUpgradeable {
    using SafeERC20 for IERC20;

    constructor(address _token, address _lzEndpoint) OFTAdapterUpgradeable(_token, _lzEndpoint) {
        _disableInitializers();
    }

    function initialize(address _delegate) public initializer {
        __OFTAdapter_init(_delegate);
        __Ownable_init(_delegate);
        __Pausable_init();
    }

    function _debit(address _from, uint256 _amountLD, uint256 _minAmountLD, uint32 _dstEid)
        internal
        override
        whenNotPaused
        returns (uint256 amountSentLD, uint256 amountReceivedLD)
    {
        (amountSentLD, amountReceivedLD) = _debitView(_amountLD, _minAmountLD, _dstEid);
        IERC20(address(innerToken)).safeTransferFrom(_from, address(this), amountSentLD);
        FiatTokenV2_2(address(innerToken)).burn(amountSentLD);
    }

    function _credit(address _to, uint256 _amountLD, uint32 /*_srcEid*/ )
        internal
        override
        whenNotPaused
        returns (uint256 amountReceivedLD)
    {
        FiatTokenV2_2(address(innerToken)).mint(_to, _amountLD);
        return _amountLD;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }
}
