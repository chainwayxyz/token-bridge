// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import { OFTAdapterUpgradeable } from "@layerzerolabs/oft-evm-upgradeable/contracts/oft/OFTAdapterUpgradeable.sol";
import { PausableUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import { FiatTokenV2_2 } from "../interfaces/IFiatTokenV2_2.sol";

contract SourceOFTAdapter is OFTAdapterUpgradeable, PausableUpgradeable {
    address public circle;
    address public destUSDCSupplySetter;
    uint256 public destUSDCSupply;

    event CircleSet(address circle);
    event DestUSDCSupplySetterSet(address destUSDCSupplySetter);
    event DestUSDCSupplySet(uint256 supply);
    event BurnedLockedUSDC(address circle, uint256 amount);

    modifier onlyCircle() {
        require(msg.sender == circle, "SourceOFTAdapter: Caller is not Circle");
        _;
    }

    modifier onlyDestUSDCSupplySetter() {
        require(msg.sender == destUSDCSupplySetter, "SourceOFTAdapter: Caller is not destUSDCSupplySetter");
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
        // If somehow reported `destUSDCSupply` is more than the actual balance, just burn the balance
        // This can happen in the edge case of destination USDC having an additional minter that is not the bridge
        uint256 balanceToBurn = destUSDCSupply > balance ? balance : destUSDCSupply;

        FiatTokenV2_2(address(innerToken)).burn(balanceToBurn);
        emit BurnedLockedUSDC(msg.sender, balanceToBurn);
    }

    function setCircle(address _circle) external onlyOwner {
        require(_circle != address(0), "SourceOFTAdapter: Circle address cannot be zero");
        circle = _circle;
        emit CircleSet(_circle);
    }

    function setDestUSDCSupplySetter(address _destUSDCSupplySetter) external onlyOwner {
        require(_destUSDCSupplySetter != address(0), "SourceOFTAdapter: destUSDCSupplySetter address cannot be zero");
        destUSDCSupplySetter = _destUSDCSupplySetter;
        emit DestUSDCSupplySetterSet(_destUSDCSupplySetter);
    }

    function setDestUSDCSupply(uint256 _destUSDCSupply) external whenPaused onlyDestUSDCSupplySetter {
        destUSDCSupply = _destUSDCSupply;
        emit DestUSDCSupplySet(_destUSDCSupply);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }
}
