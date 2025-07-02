// SPDX-License-Identifier: Apache 2.0

pragma solidity 0.8.4;

import "./Tether/TetherTokenV2.sol";

/*

   Copyright Tether.to 2024

   Author Will Norden

   Licensed under the Apache License, Version 2.0
   http://www.apache.org/licenses/LICENSE-2.0

*/


contract TetherTokenOFTExtension is TetherTokenV2 {

  event LogSetOFTContract(address indexed oftContract);
  event Burn(address indexed from, uint256 amount);

  address public oftContract;

  string internal _newName; // Unused variable for compatibility
  string internal _newSymbol; // Unused variable for compatibility

  modifier onlyAuthorizedSender() {
    require(msg.sender == oftContract, "Only OFT can call");
    _;
  }

  function mint(address _destination, uint256 _amount) public override onlyAuthorizedSender {
    _mint(_destination, _amount);
    emit Mint(_destination, _amount);
  }

  function burn(address _from, uint256 _amount) public onlyAuthorizedSender {
    _burn(_from, _amount);
    emit Burn(_from, _amount);
  }

  function setOFTContract(address _oftContract) external onlyOwner {
    oftContract = _oftContract;
    emit LogSetOFTContract(_oftContract);
  }

  uint256[47] private __gap;
}
