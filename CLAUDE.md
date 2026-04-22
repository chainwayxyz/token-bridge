# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a stablecoin bridge implementation connecting EVM chains using LayerZero v2. It supports bridging USDC, USDT, and WBTC between a source chain (e.g., Ethereum) and a destination chain. The USDC bridge strictly conforms to [Circle's Bridged USDC Standard](https://circle.com/blog/bridged-usdc-standard) to enable future migration to native USDC.

## Core Architecture

### Bridge Design Pattern

The codebase implements a **mint-and-burn bridge** model using LayerZero's Omnichain Fungible Token (OFT) standard:

- **Source Chain**: Uses adapter contracts (`SourceOFTAdapter`, `WBTCOFTAdapter`) that lock tokens when bridging
- **Destination Chain**: Uses OFT contracts (`DestinationOUSDC`, `DestinationOUSDT`, `WBTCOFT`) that mint/burn bridged tokens
- All contracts are **upgradeable** to support future changes, especially Circle takeover requirements

### Key Contracts

#### USDC Bridge
- `src/SourceOFTAdapter.sol`: Source chain adapter (locks USDC)
- `src/DestinationOUSDC.sol`: Destination chain contract (mints/burns bridged USDC)
- `src/for_circle_takeover/`: Upgraded versions adding pause and burn functionality for Circle migration
- `src/USDCRolesHolder.sol`: Intermediary contract holding USDC roles during Circle transfer

#### USDT Bridge
- `src/usdt0/`: Contains USDT token implementation (TetherTokenV2) and OFT extension
- `src/DestinationOUSDT.sol`: Destination chain contract for USDT
- Uses same adapter pattern as USDC

#### WBTC Bridge
- `src/wbtc/WBTCOFTAdapter.sol`: Source chain adapter
- `src/wbtc/WBTCOFT.sol`: Destination chain token contract
- `src/wbtc/OFTFee.sol` and `src/wbtc/OFTFeeAdapter.sol`: Base contracts with fee support
- Uses 8 decimals (satoshi precision)

### Configuration System

The project uses a **TOML-based configuration** system in `config/<mainnet|testnet>/config.toml`:
- Chain-specific settings (RPC, verifier, LayerZero endpoints)
- LayerZero configuration (DVNs, confirmations, gas limits)
- Token initialization parameters (owners, proxy admins, names, symbols)
- Deployment addresses (populated by scripts)

The `ConfigSetup.s.sol` base contract reads these TOML files and makes values available to all deployment scripts.

### Deployment Scripts

Deployment is **sequential and multi-step**. Each stablecoin has numbered scripts in `script/<coin>/deploy/`:

**Example flow (USDC):**
1. Deploy token (Circle's script for USDC, or Foundry script)
2. Deploy source bridge
3. Deploy destination bridge
4. Configure LayerZero settings (ULN config, DVNs)
5. Set bridge as minter on token
6. Set peers (connect both bridge ends)
7. Assign roles to designated owners
8. Run post-deployment tests

**Circle Takeover** (USDC only): Scripts in `script/usdc/for_circle_takeover/` handle the migration process per the Bridged USDC Standard:
- Upgrade bridge contracts to add pause/burn functionality
- Set BlockedMsgLib to prevent new messages
- Pause bridges after confirming no inflight messages
- Transfer USDC roles to Circle via USDCRolesHolder

## Common Commands

### Prerequisites Setup
```bash
# Install dependencies
forge install

# Setup environment variables
cp .env.example .env
# Edit .env to set: NETWORK, ACCOUNT_NAME, PASSWORD, and API keys

# Import deployer account
source .env
cast wallet import $ACCOUNT_NAME --unsafe-password $PASSWORD --interactive
```

### Building and Testing
```bash
# Build contracts
forge build

# Run all tests
forge test

# Run specific test file
forge test --match-path test/usdc/deploy/02_USDCSrcBridgeDeploy.t.sol

# Run tests with verbosity
forge test -vvv

# Run post-deployment tests (requires IS_POST_DEPLOYMENT env var)
IS_POST_DEPLOYMENT=true forge test --match-path test/usdc/post_deployment/USDCPostDeployment.t.sol
```

### Deployment

**USDC:**
```bash
# Deploy USDC token and bridge
make usdc-and-bridge

# Deploy only USDC token
make usdc-deploy

# Deploy only USDC bridge (token must exist)
make usdc-bridge-full

# Test USDC bridge
make usdc-bridge-mint-test  # Source -> Destination
make usdc-bridge-burn-test  # Destination -> Source
```

**USDT:**
```bash
# Deploy USDT token and bridge
make usdt-and-bridge

# Deploy only USDT token
make usdt-deploy

# Deploy only USDT bridge
make usdt-bridge-full

# Test USDT bridge
make usdt-bridge-mint-test
make usdt-bridge-burn-test
```

**WBTC:**
```bash
# Deploy WBTC bridge (includes token on destination)
make wbtc-bridge-full

# Test WBTC bridge
make wbtc-bridge-mint-test
make wbtc-bridge-burn-test
```

### Manual Script Execution

For individual deployment steps or Circle takeover:
```bash
# Run individual deployment script
forge script ./script/usdc/deploy/02_USDCSrcBridgeDeploy.s.sol \
  --sender $(DEPLOYER_ADDRESS) \
  --account $(ACCOUNT_NAME) \
  --password $(PASSWORD) \
  --broadcast \
  --verify \
  --verifier <verifier> \
  --verifier-url <url>

# Circle takeover scripts (run with specific private keys)
forge script ./script/usdc/for_circle_takeover/05_USDCSrcBridgePause.s.sol \
  --private-key <OWNER_PRIVATE_KEY> \
  --broadcast \
  --ffi  # Required for inflight message checking
```

### Utility Commands

```bash
# Clear deployment addresses from config (before redeployment)
python3 -m venv ".clear-usdc-deployments"
./.clear-usdc-deployments/bin/python -m pip install tomli tomli-w dotenv
./.clear-usdc-deployments/bin/python ./script/ClearDeploymentsFromConfig.py usdc
```

## Development Notes

### LayerZero Integration

- **Version**: LayerZero v2
- **Endpoint**: Each chain has a LayerZero endpoint contract (see config)
- **DVNs**: Decentralized Verifier Networks validate cross-chain messages
- **Peers**: Both bridge ends must be configured as peers via `setPeer()`
- **Options**: Destination gas and other parameters encoded via `enforcedOptions`

### Configuration Requirements

When configuring `config/<network>/config.toml`:
- `src.*` fields: Source chain (where native tokens exist)
- `dest.*` fields: Destination chain (where bridged tokens are minted)
- LayerZero EIDs must match official values for each chain
- `confirmations`: Number of block confirmations (use 15+ for security)
- DVN addresses must be valid LayerZero DVNs for the respective chains

### Security Considerations

- **Deployer Privileges**: Deployment scripts temporarily grant roles to the deployer, then transfer them. Always verify deployer has no privileged roles after deployment.
- **Upgradeable Contracts**: All bridge contracts use UUPS proxy pattern. Proxy admins control upgrades.
- **Circle Takeover**: The `for_circle_takeover` upgrade path is critical for USDC. Scripts check for inflight messages and require FFI flag.
- **USDT Fee-on-Transfer**: If source USDT has fees enabled, bridge logic needs adjustment (see README warning).

### Comparison with USDT0

This codebase's LayerZero integration is nearly identical to [USDT0](https://usdt0.to):
- `SourceOFTAdapter` ≈ USDT0's `OAdapterUpgradeable` ([Ethereum mainnet](https://etherscan.io/address/0xcd979b10a55fcdac23ec785ce3066c6ef8a479a4#code))
- `DestinationOUSDT` ≈ USDT0's `OUpgradeable` ([Unichain](https://unichain.blockscout.com/address/0x13C41AF9e2AdaDB47A55961f6D3B68B41ae36eF9?tab=contract))
- `DestinationOUSDC` has minimal changes from `DestinationOUSDT` to accommodate USDC's minting requirements

### Testing Patterns

- Each deployment script has a corresponding test in `test/<coin>/deploy/`
- Tests inherit from base contracts (e.g., `USDCBridgeDeployBase.t.sol`)
- Post-deployment tests verify the complete setup using `IS_POST_DEPLOYMENT=true`
- For Circle takeover scripts, see `test/usdc/for_circle_takeover/`

## Important Files

- `script/ConfigSetup.s.sol`: Base contract that reads TOML config for all scripts
- `foundry.toml`: Solidity compiler settings, remappings, and file system permissions
- `Makefile`: Orchestrates multi-step deployments
- `script/ClearDeploymentsFromConfig.py`: Python utility to reset deployment addresses
- `bridged_USDC_standard.md`: Circle's specification (with code annotations in commit history)
- `auditors_guide.md`: Guide for auditors reviewing the codebase

## WBTC-Specific Details

- WBTC uses **8 decimals** (satoshi precision) vs 6 for USDC/USDT
- The destination bridge (`WBTCOFT`) **is also the token contract** (not separate like USDC/USDT)
- Source adapter (`WBTCOFTAdapter`) locks existing WBTC on source chain
- Fee functionality exists in base contracts but may not be actively used
