// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "openzeppelin-contracts/contracts/access/Ownable2Step.sol";
import "../src/interfaces/IFiatTokenV2_2.sol";

contract USDCRolesHolder is Ownable2Step {
    FiatTokenV2_2 public immutable usdc;
    address public circle;

    event CircleSet(address circle);
    event USDCRolesTransferred(address newOwner);

    modifier onlyCircle() {
        require(msg.sender == circle, "USDCRolesHolder: Caller is not Circle");
        _;
    }

    constructor (address _owner, address usdcProxy) Ownable(_owner) {
        usdc = FiatTokenV2_2(usdcProxy);
    }

    function setCircle(address _circle) external onlyOwner {
        require(_circle != address(0), "USDCRolesHolder: Circle address cannot be zero");
        circle = _circle;
        emit CircleSet(_circle);
    }

    function transferUSDCRoles(address _owner) external onlyCircle {
        usdc.transferOwnership(_owner);
        emit USDCRolesTransferred(_owner);
    }
}