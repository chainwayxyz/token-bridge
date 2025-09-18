// SPDX-License-Identifier: Apache 2.0
pragma solidity ^0.8.4;

interface TetherTokenOFTExtension {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event AuthorizationCanceled(address indexed authorizer, bytes32 indexed nonce);
    event AuthorizationUsed(address indexed authorizer, bytes32 indexed nonce);
    event BlockPlaced(address indexed _user);
    event BlockReleased(address indexed _user);
    event Burn(address indexed from, uint256 amount);
    event CrosschainBurn(address indexed from, uint256 amount, address indexed sender);
    event CrosschainMint(address indexed to, uint256 amount, address indexed sender);
    event DestroyedBlockedFunds(address indexed _blockedUser, uint256 _balance);
    event LogSetOFTContract(address indexed oftContract);
    event LogUpdateNameAndSymbol(string name, string symbol);
    event Mint(address indexed _destination, uint256 _amount);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Redeem(uint256 _amount);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function CANCEL_AUTHORIZATION_TYPEHASH() external view returns (bytes32);
    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function RECEIVE_WITH_AUTHORIZATION_TYPEHASH() external view returns (bytes32);
    function TRANSFER_WITH_AUTHORIZATION_TYPEHASH() external view returns (bytes32);
    function addToBlockedList(address _user) external;
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function authorizationState(address authorizer, bytes32 nonce) external view returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function cancelAuthorization(address authorizer, bytes32 nonce, uint8 v, bytes32 r, bytes32 s) external;
    function cancelAuthorization(address authorizer, bytes32 nonce, bytes memory signature) external;
    function crosschainBurn(address _from, uint256 _amount) external;
    function crosschainMint(address _destination, uint256 _amount) external;
    function decimals() external view returns (uint8);
    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);
    function destroyBlockedFunds(address _blockedUser) external;
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);
    function initialize(string memory _name, string memory _symbol, uint8 _decimals) external;
    function isBlocked(address) external view returns (bool);
    function isTrusted(address) external view returns (bool);
    function mint(address _destination, uint256 _amount) external;
    function multiTransfer(address[] memory _recipients, uint256[] memory _values) external;
    function name() external view returns (string memory);
    function nonces(address owner) external view returns (uint256);
    function oftContract() external view returns (address);
    function owner() external view returns (address);
    function permit(address owner_, address spender, uint256 value, uint256 deadline, bytes memory signature)
        external;
    function permit(address owner_, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s)
        external;
    function receiveWithAuthorization(
        address from,
        address to,
        uint256 value,
        uint256 validAfter,
        uint256 validBefore,
        bytes32 nonce,
        bytes memory signature
    ) external;
    function receiveWithAuthorization(
        address from,
        address to,
        uint256 value,
        uint256 validAfter,
        uint256 validBefore,
        bytes32 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
    function redeem(uint256 _amount) external;
    function removeFromBlockedList(address _user) external;
    function renounceOwnership() external;
    function setOFTContract(address _oftContract) external;
    function supportsInterface(bytes4 interfaceId) external pure returns (bool);
    function symbol() external view returns (string memory);
    function totalSupply() external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address _sender, address _recipient, uint256 _amount) external returns (bool);
    function transferOwnership(address newOwner) external;
    function transferWithAuthorization(
        address from,
        address to,
        uint256 value,
        uint256 validAfter,
        uint256 validBefore,
        bytes32 nonce,
        bytes memory signature
    ) external;
    function transferWithAuthorization(
        address from,
        address to,
        uint256 value,
        uint256 validAfter,
        uint256 validBefore,
        bytes32 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
    function updateNameAndSymbol(string memory _name, string memory _symbol) external;
}
