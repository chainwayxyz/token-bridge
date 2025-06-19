// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "../interfaces/IFiatTokenV2_2.sol";

contract USDCRolesHolder is Ownable {
    IFiatTokenV2_2 public usdc;

    event CircleSet(address circle);
    event USDCRolesTransferred(address newOwner);

    constructor (address _owner, address usdcProxy) Ownable(_owner) {
        usdc = IFiatTokenV2_2(usdcProxy);
    }

    function setCircle(address _circle) external onlyOwner {
        require(_circle != address(0), "USDCRolesHolder: Circle address cannot be zero");
        circle = _circle;
        emit CircleSet(_circle);
    }

    function transferUSDCRoles(address _owner) external onlyCircle {
        usdc.transferOwnership(_owner);
        emit USDCRolesTransferred(_owner);
        // TODO: Additionally, the partner is expected to remove all configured minters prior to (or concurrently with) transferring the roles to Circle.
    }
}