// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import { OFTAdapterUpgradeable } from "@layerzerolabs/oft-evm-upgradeable/contracts/oft/OFTAdapterUpgradeable.sol";
import { PausableUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import { FiatTokenV2_2 } from "../interfaces/IFiatTokenV2_2.sol";

contract SourceOFTAdapter is OFTAdapterUpgradeable, PausableUpgradeable {
    address public circle;

    event CircleSet(address circle);
    event BurnedLockedUSDC(address circle, uint256 amount);

    modifier onlyCircle() {
        require(msg.sender == circle, "SourceOFTAdapter: Caller is not Circle");
        _;
    }

    constructor(address _token, address _lzEndpoint) OFTAdapterUpgradeable(_token, _lzEndpoint) {
        _disableInitializers();
    }

    function initialize(address _delegate) public initializer {
        __OFTAdapter_init(_delegate);
        __Ownable_init(_delegate);
        __Pausable_init();
    }

    function _debit(
        address _from,
        uint256 _amountLD,
        uint256 _minAmountLD,
        uint32 _dstEid
    ) internal virtual override whenNotPaused returns (uint256 amountSentLD, uint256 amountReceivedLD) {
        (amountSentLD, amountReceivedLD) = super._debit(_from, _amountLD, _minAmountLD, _dstEid);
    }

    function _credit(
        address _to,
        uint256 _amountLD,
        uint32 _srcEid
    ) internal virtual override whenNotPaused returns (uint256 amountReceivedLD) {
        amountReceivedLD = super._credit(_to, _amountLD, _srcEid);
    }

    function burnLockedUSDC() external onlyCircle {
        uint256 balance = innerToken.balanceOf(address(this));
        FiatTokenV2_2(address(innerToken)).burn(balance);
        emit BurnedLockedUSDC(msg.sender, balance);
    }

    function setCircle(address _circle) external onlyOwner {
        require(_circle != address(0), "SourceOFTAdapter: Circle address cannot be zero");
        circle = _circle;
        emit CircleSet(_circle);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }
}
