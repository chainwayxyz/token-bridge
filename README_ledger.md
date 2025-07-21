This is `README.md` but with instructions for Ledger.

Firstly set your HD_PATH environment variable so that it can be used in the scripts:

```
export HD_PATHS=<YOUR_HD_PATHS>
```

If bridge is going to work with already deployed stablecoins on Citrea, go to section 2 of respective stablecoins.

If you wish to test an existing bridge, go to section 3 of respective stablecoins.

## USDC
### 1. Deploying USDC
1. Fill `./stablecoin-evm_env/.env.citrea-usdc` for the following variables, for `PROXY_ADMIN_ADDRESS` use a different address than the one `DEPLOYER_PRIVATE_KEY` corresponds to:

```
DEPLOYER_PRIVATE_KEY=
PROXY_ADMIN_ADDRESS=
OWNER_ADDRESS=
MASTER_MINTER_OWNER_ADDRESS=
```

2. Deploy USDC `FiatTokenv2_2` contracts to Citrea via Deployment section in [USDC README](https://github.com/circlefin/stablecoin-evm).

```
cd ..
git clone https://github.com/circlefin/stablecoin-evm.git
cd stablecoin-evm
cp ../stablecoin-bridge/stablecoin-evm_env/.env.citrea-usdc .env
echo "[]" > blacklist.remote.json
yarn install
yarn forge:simulate scripts/deploy/deploy-fiat-token.s.sol --rpc-url <testnet OR mainnet>
yarn forge:broadcast scripts/deploy/deploy-fiat-token.s.sol --rpc-url <testnet OR mainnet>
cd ../stablecoin-bridge
```

3. Fill `config/<mainnet or testnet>/config.toml` file with the following variables and push to repository:

```
citrea.usdc.proxy=<FiatTokenProxy in previous step>
citrea.usdc.masterMinter=<MasterMinter in previous step>
```

4. Save the compilation output for verification. Copy the compilation outputs of the relevant contracts to this repository if canonical deployment. This step is not critical since the deployment of USDC is done through official Circle scripts, and Blockscout can automatically verify the contracts due to bytecode equivalence.

### 2. Deploying USDC Bridge
1. Fill the fields of `[citrea.usdc.bridge.init]` and `[eth.usdc.bridge.init]` in `config/<mainnet or testnet>/config.toml`.

2. Run the bridge deployment script:
```
forge script ./script/USDCBridgeDeploy.s.sol --ledger --hd-paths $HD_PATHS --broadcast
```

3. Fill the fields of `[citrea.usdc.bridge.deployment]` and `[eth.usdc.bridge.deployment]` in `config/<mainnet or testnet>/config.toml`.

### 3. Testing USDC Bridge
1. Test the deployment by running the test script which sends 1 cent from Ethereum to Citrea, you need to have some USDC on Ethereum for this:
```
forge script ./script/test/USDCBridgeMintTest.s.sol --ledger --hd-paths $HD_PATHS --broadcast
```

2. If the script is successful, search for the `send` transaction (the other one is approval) in the output of the script on LayerZero Scan. Wait for the destination transaction hash, look it up on Citrea Explorer, and confirm that Citrea USDC was minted to the address associated with the private key used above.

3. Similarly, run the test script which sends 1 cent from Citrea to Ethereum, you need to have some bridged USDC on Citrea for this:

```
forge script ./script/test/USDCBridgeBurnTest.s.sol --ledger --hd-paths $HD_PATHS --broadcast
```

4. If the script is successful, search for the `send` transaction (the other one is approval) in the output of the script on LayerZero Scan. Wait for the destination transaction hash, look it up on Ethereum Explorer, and confirm that USDC was burned from Citrea and 1 cent was sent to the address associated with the private key used above.

### 4. Upgrading the USDC Bridge for Circle takeover

1. Upgrade the USDC bridge contracts to the Circle takeover version by running the upgrade script from respective proxy admin owners:

```
forge script ./script/for_circle_takeover/prepare_takeover/USDCDestBridgePrepareTakeover.s.sol --ledger --hd-paths $HD_PATHS --broadcast
forge script ./script/for_circle_takeover/prepare_takeover/USDCSrcBridgePrepareTakeover.s.sol --ledger --hd-paths $HD_PATHS --broadcast
```

2. Set Circle's address so they can perform the USDC burn action on Ethereum end of the bridge:

```
SRC_BRIDGE_CIRCLE_ADDRESS=<ADDRESS_GIVEN_BY_CIRCLE> forge script ./script/for_circle_takeover/USDCSrcBridgeSetCircle.s.sol --ledger --hd-paths $HD_PATHS --broadcast
```

3. Pause both ends of the bridge, should be called by respective bridge owners:

```
forge script ./script/for_circle_takeover/pause/USDCDestBridgePause.s.sol --ledger --hd-paths $HD_PATHS --broadcast
forge script ./script/for_circle_takeover/pause/USDCSrcBridgePause.s.sol --ledger --hd-paths $HD_PATHS --broadcast
```

4. Transfer the proxy admin of USDC to Circle's given address:

```
CIRCLE_USDC_PROXY_ADMIN=<ADDRESS_GIVEN_BY_CIRCLE> forge script ./script/for_circle_takeover/USDCProxyAdminTransfer.s.sol --ledger --hd-paths $HD_PATHS --broadcast
```

5. Transfer USDC's ownership to a contract that Circle can later use to retrieve the ownership of USDC, `USDC_ROLES_HOLDER_OWNER` should be in our control:

```
USDC_ROLES_HOLDER_OWNER=<OWNER_ADDRESS> forge script ./script/for_circle_takeover/USDCTransferOwner.s.sol --ledger --hd-paths $HD_PATHS --broadcast
```

6. Set the Circle's address in `USDCRolesHolder` contract:

```
USDC_ROLES_HOLDER_CIRCLE_ADDRESS=<ADDRESS_GIVEN_BY_CIRCLE> forge script ./script/for_circle_takeover/USDCRolesHolderSetCircle.s.sol --ledger --hd-paths $HD_PATHS --broadcast
```

7. Remove bridge's minter role from USDC, should be called by `MasterMinter`'s owner:

```
forge script ./script/for_circle_takeover/USDCRemoveBridgeAsMinter.s.sol --ledger --hd-paths $HD_PATHS --broadcast
```

## USDT
### 1. Deploying USDT

1. Run the USDT deployment script after filling `[citrea.usdt.init]`:
```
forge script ./script/USDTDeploy.s.sol --ledger --hd-paths $HD_PATHS --broadcast
```

2. Fill the fields of `[citrea.usdt.deployment]` in `config/<mainnet or testnet>/config.toml`.

### 2. Deploying USDT Bridge
1. Fill the fields of `[citrea.usdt.bridge.init]` and `[eth.usdt.bridge.init]` in `config/<mainnet or testnet>/config.toml`.

2. Run the bridge deployment script:
```
forge script ./script/USDTBridgeDeploy.s.sol --ledger --hd-paths $HD_PATHS --broadcast
```

3. Fill the fields of `[citrea.usdt.bridge.deployment]` and `[eth.usdt.bridge.deployment]` in `config/<mainnet or testnet>/config.toml`.

4. Set the bridge as a minter for USDT:
```
forge script ./script/USDTSetBridgeAsMinter.s.sol --ledger --hd-paths $HD_PATHS --broadcast
```

### 3. Testing USDT Bridge
1. Test the deployment by running the test script which sends 1 cent from Ethereum to Citrea, you need to have some USDT on Ethereum for this:
```
forge script ./script/test/USDTBridgeMintTest.s.sol --ledger --hd-paths $HD_PATHS --broadcast
```

2. If the script is successful, search for the `send` transaction (the other one is approval) in the output of the script on LayerZero Scan. Wait for the destination transaction hash, look it up on Citrea Explorer, and confirm that Citrea USDT was minted to the address associated with the private key used above.

3. Similarly, run the test script which sends 1 cent from Citrea to Ethereum, you need to have some bridged USDT on Citrea for this:

```
forge script ./script/test/USDTBridgeBurnTest.s.sol --ledger --hd-paths $HD_PATHS --broadcast
```

4. If the script is successful, search for the `send` transaction (the other one is approval) in the output of the script on LayerZero Scan. Wait for the destination transaction hash, look it up on Ethereum Explorer, and confirm that USDT was burned from Citrea and 1 cent was sent to the address associated with the private key used above.