If you are looking to review this repository, please read [the auditor's guide](auditors_guide.md) first.

If bridge is going to work with already deployed stablecoins on destination chain, go to section 3 of respective stablecoins.

If you wish to test an existing bridge, go to section 4 of respective stablecoins.

## Setting up the environment

### Prerequisites
- [Foundry](https://getfoundry.sh/introduction/installation#installation)
- python3
- jq
- yq

For macOS, `python3` is installed by default, and `jq` and `yq` can be installed via Homebrew:
```bash
brew install jq yq
```

Install the dependencies for the contracts and scripts in this repository:
```
forge install
```

Circle's USDC deployment scripts may require a different `node` and `yarn` versions than the ones installed by default on your system. It is recommended to use `nvm` to set the `node` version, and `yarn set version` to set the `yarn` version. The required versions are:
- `node`: 20.18.0
- `yarn`: 1.22.19

### Setting the environment variables and the deployer
1. Copy `.env.example` to `.env` in the root directory of this repository. Set a `PASSWORD` and `ACCOUNT_NAME` for the deploy address. The private key for the deployer address will be encrypted with this password. Set the `NETWORK` depending on if this is a mainnet or testnet deployment.
```
cp .env.example .env
```

2. Create an account that will function as the deployer address, and set the private key of that account through Foundry keystore:
```
source .env
cast wallet import $ACCOUNT_NAME --unsafe-password $PASSWORD --interactive
```

3. Fund this address with some native assets on both `src` and `dest` chains to pay for gas. Also fund it with USDC and USDT on `src` chain if you are going to test the bridge. 1 cent of each stablecoin is enough for testing.

## USDC
### 1. Deploying both USDC and USDC Bridge
1. Fill all `[*.usdc.*]` fields except the ones ending with `.deployment` in `config/<mainnet or testnet>/config.toml`.

2. Run the deployment commands:
```
make usdc-and-bridge
```

3. Verify that `make` exited successfully, you should see a message with the ✅ emoji if all steps are completed without errors.

4. Save the USDC compilation output for verification. Copy the compilation outputs of the relevant contracts to this repository if canonical deployment. This step is not critical since the deployment of USDC is done through official Circle scripts, and Blockscout can automatically verify the contracts due to bytecode equivalence. You can find the compilation outputs in the created `stablecoin-evm` directory under the root level of this repository. Copying `broadcast/deploy-fiat-token.s.sol/<your-chain-id>/run-latest.json` and the `artifacts/foundry` directory is a good practice in case something goes wrong later.

5. Go to [section 4](#4-testing-usdc-bridge) to test the bridge.

### 2. Deploying USDC only
1. Run the USDC deployment script after filling `[dest.usdc.init]`:
```
make usdc-deploy
```

2. Verify that `make` exited successfully, you should see a message with the ✅ emoji if all steps are completed without errors.

3. Save the compilation output for verification. Copy the compilation outputs of the relevant contracts to this repository if canonical deployment. This step is not critical since the deployment of USDC is done through official Circle scripts, and Blockscout can automatically verify the contracts due to bytecode equivalence. You can find the compilation outputs in the created `stablecoin-evm` directory under the root level of this repository. Copying `broadcast/deploy-fiat-token.s.sol/<your-chain-id>/run-latest.json` and the `artifacts/foundry` directory is a good practice in case something goes wrong later.

### 3. Deploying USDC Bridge only
1. Fill the fields of `[dest.usdc.bridge.init]` and `[src.usdc.bridge.init]` in `config/<mainnet or testnet>/config.toml`.

2. Run the bridge deployment script:
```
make usdc-bridge-full
```

3. Verify that `make` exited successfully, you should see a message with the ✅ emoji if all steps are completed without errors.

### 4. Testing USDC Bridge
1. Test the deployment by running the test script which sends 1 cent from source chain to destination chain, you need to have some USDC on source chain for this:
```
make usdc-bridge-mint-test
```

2. If the script is successful, search for the `send` transaction (the other one is approval) in the output of the script on LayerZero Scan. Wait for the destination transaction hash, look it up on destination chain explorer, and confirm that destination chain USDC was minted to the address associated with the private key used above.

3. Similarly, run the test script which sends 1 cent from destination chain to source chain, you need to have some bridged USDC on destination chain for this:

```
make usdc-bridge-burn-test
```

4. If the script is successful, search for the `send` transaction (the other one is approval) in the output of the script on LayerZero Scan. Wait for the destination transaction hash, look it up on source chain explorer, and confirm that USDC was burned from destination chain and 1 cent was sent to the address associated with the private key used above.

### 5. Upgrading the USDC Bridge for Circle takeover

1. Upgrade the USDC bridge contracts to the Circle takeover version by running the upgrade script from respective proxy admin owners:

```
forge script ./script/usdc/for_circle_takeover/01_USDCSrcBridgePrepareTakeover.s.sol --private-key <SRC_USDC_BRIDGE_PROXY_ADMIN_OWNER_PRIVATE_KEY> --broadcast

forge script ./script/usdc/for_circle_takeover/02_USDCDestBridgePrepareTakeover.s.sol --private-key <DEST_USDC_BRIDGE_PROXY_ADMIN_OWNER_PRIVATE_KEY> --broadcast
```

2. Set the `BlockedMsgLib` as the send library of both ends of the bridge, should be called by respective bridge owners:

```
SRC_LZ_BLOCKED_MSG_LIB=<BLOCKED_MSG_LIB_ON_SRC> forge script ./script/usdc/for_circle_takeover/03_USDCSrcBridgeSetBlockedMsgLib.s.sol --private-key <SRC_USDC_BRIDGE_OWNER_PRIVATE_KEY> --broadcast

DEST_LZ_BLOCKED_MSG_LIB=<BLOCKED_MSG_LIB_ON_DEST> forge script ./script/usdc/for_circle_takeover/04_USDCDestBridgeSetBlockedMsgLib.s.sol --private-key <DEST_USDC_BRIDGE_OWNER_PRIVATE_KEY> --broadcast
```

This is done to prevent messages being sent out so that they do not get stuck after the bridge is paused in the next step. Wait for a while after this step and ensure there are no messages inflight by checking LayerZero Scan before proceeding with pausing the bridge.

3. Pause both ends of the bridge, should be called by respective bridge owners:

```
forge script ./script/usdc/for_circle_takeover/05_USDCSrcBridgePause.s.sol --private-key <SRC_USDC_BRIDGE_OWNER_PRIVATE_KEY> --broadcast

forge script ./script/usdc/for_circle_takeover/06_USDCDestBridgePause.s.sol --private-key <DEST_USDC_BRIDGE_OWNER_PRIVATE_KEY> --broadcast
```

4. Remove bridge's minter role from destination USDC, should be called by `MasterMinter`'s owner:

```
forge script ./script/usdc/for_circle_takeover/07_USDCRemoveBridgeAsMinter.s.sol --private-key <MASTER_MINTER_OWNER_ADDRESS_PRIVATE_KEY> --broadcast
```

5. Set Circle's address so they can perform the USDC burn action on source chain end of the bridge. This script also sets the destination USDC total supply by reading from the destination chain so that Circle can burn the correct amount of USDC on source chain. This script should be called by the source USDC bridge owner:

```
SRC_BRIDGE_CIRCLE_ADDRESS=<ADDRESS_GIVEN_BY_CIRCLE> forge script ./script/usdc/for_circle_takeover/08_USDCSrcBridgeSetCircleAndDestSupply.s.sol --private-key <SRC_USDC_BRIDGE_OWNER_PRIVATE_KEY> --broadcast
```

> [!WARNING]
> Make sure reported destination USDC total supply in logs of the above script matches with the actual value by checking it on destination chain explorer. If the value is incorrect, do not proceed with the next steps and investigate the issue. In this script, total supply of USDC on destination chain is read directly from destination RPC. If RPC is not reliable, you may consider deploying a cross-chain reader contract utilizing `lzRead` and use that contract as the `destUSDCSupplySetter` instead.

6. Transfer the proxy admin of USDC to Circle's given address:

```
CIRCLE_USDC_PROXY_ADMIN=<ADDRESS_GIVEN_BY_CIRCLE> forge script ./script/usdc/for_circle_takeover/09_USDCProxyAdminTransfer.s.sol --private-key <DEST_USDC_BRIDGE_PROXY_ADMIN_OWNER_PRIVATE_KEY> --broadcast
```

7. Transfer USDC's ownership to a contract that Circle can later use to retrieve the ownership of USDC, `USDC_ROLES_HOLDER_OWNER` should be in our control:

```
USDC_ROLES_HOLDER_OWNER=<OWNER_ADDRESS> forge script ./script/usdc/for_circle_takeover/10_USDCTransferOwner.s.sol --private-key <DEST_USDC_BRIDGE_OWNER_PRIVATE_KEY> --broadcast
```

8. Set the Circle's address in `USDCRolesHolder` contract:

```
USDC_ROLES_HOLDER_CIRCLE_ADDRESS=<ADDRESS_GIVEN_BY_CIRCLE> forge script ./script/usdc/for_circle_takeover/11_USDCRolesHolderSetCircle.s.sol --private-key <USDC_ROLES_HOLDER_OWNER_PRIVATE_KEY> --broadcast
```

## USDT

> [!NOTE]
> Bridge logic in this protocol assumes lossless 1:1 transfers. If USDT on your source chain has fee-on-transfer enabled, you may need to adjust the logic accordingly. See [line 131 of the USDT contract on Ethereum Mainnet](https://etherscan.io/token/0xdac17f958d2ee523a2206206994597c13d831ec7#code#L131) as reference for the fee-on-transfer logic.

### 1. Deploying both USDT and USDT Bridge
1. Fill all `[*.usdt.*]` fields except the ones ending with `.deployment` in `config/<mainnet or testnet>/config.toml`.

2. Run the deployment commands:
```
make usdt-and-bridge
```

3. Verify that `make` exited successfully, you should see a message with the ✅ emoji if all steps are completed without errors.

4. Go to [section 4](#4-testing-usdt-bridge) to test the bridge.

### 2. Deploying USDT only

1. Run the USDT deployment script after filling `[dest.usdt.init]`:
```
make usdt-deploy
```

2. Verify that `make` exited successfully, you should see a message with the ✅ emoji if all steps are completed without errors.

### 3. Deploying USDT Bridge only
1. Fill the fields of `[dest.usdt.bridge.init]` and `[src.usdt.bridge.init]` in `config/<mainnet or testnet>/config.toml`.

2. Run the bridge deployment script:
```
make usdt-bridge-full
```

3. Verify that `make` exited successfully, you should see a message with the ✅ emoji if all steps are completed without errors.

### 4. Testing USDT Bridge
1. Test the deployment by running the test script which sends 1 cent from source chain to destination chain, you need to have some USDT on source chain for this:
```
make usdt-bridge-mint-test
```

2. If the script is successful, search for the `send` transaction (the other one is approval) in the output of the script on LayerZero Scan. Wait for the destination transaction hash, look it up on destination chain explorer, and confirm that destination chain USDT was minted to the address associated with the private key used above.

3. Similarly, run the test script which sends 1 cent from destination chain to source chain, you need to have some bridged USDT on destination chain for this:

```
make usdt-bridge-burn-test
```

4. If the script is successful, search for the `send` transaction (the other one is approval) in the output of the script on LayerZero Scan. Wait for the destination transaction hash, look it up on source chain explorer, and confirm that USDT was burned from destination chain and 1 cent was sent to the address associated with the private key used above.