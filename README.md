If you are looking to review this repository, please read [the auditor's guide](auditors_guide.md) first.

If bridge is going to work with already deployed USDC on Citrea, go to section 2.

If you wish to test an existing LZ-USDC bridge, go to section 3.

## 1. Deploying USDC
1. Depending on the network, copy the necessary .env file, and fill `CITREA_USDC_PROXY_ADMIN_OWNER`.

```
cp .env.<mainnet or testnet> .env
```

2. Deploy a proxy admin contract to be used as the proxy admin for USDC.

```
forge script ./script/USDCProxyAdminDeploy.s.sol --private-key <YOUR_PRIVATE_KEY> --broadcast
```

3. Fill `./stablecoin-evm_env/.env.citrea-usdc` for the following variables, for `PROXY_ADMIN_ADDRESS` use the address that got deployed in the previous step:

```
DEPLOYER_PRIVATE_KEY=
PROXY_ADMIN_ADDRESS=
OWNER_ADDRESS=
MASTER_MINTER_OWNER_ADDRESS=
```

4. Deploy USDC `FiatTokenv2_2` contracts to Citrea via Deployment section in [USDC README](https://github.com/circlefin/stablecoin-evm).

```
cd ..
git clone https://github.com/circlefin/stablecoin-evm.git
cd stablecoin-evm
cp ../bridged-usdc-citrea/stablecoin-evm_env/.env.citrea-usdc .env
echo "[]" > blacklist.remote.json
yarn forge:simulate scripts/deploy/deploy-fiat-token.s.sol --rpc-url <testnet OR mainnet>
yarn forge:broadcast scripts/deploy/deploy-fiat-token.s.sol --rpc-url <testnet OR mainnet>
yarn forge:verify scripts/deploy/deploy-fiat-token.s.sol --rpc-url <testnet OR mainnet>
cd ../bridged-usdc-citrea
```

5. Fill `.env` and `.env.<mainnet or testnet>` files with the following variables and push to repository:

```
CITREA_USDC=<FiatTokenProxy in previous step>
CITREA_MM=<MasterMinter in previous step>
```

// TODO: Add more detail.
6. Save the compilation output for verification.

## 2. Deploying USDC Bridge
1. If section 1 is skipped, depending on the network, copy the necessary .env file:
```
cp .env.<mainnet or testnet> .env
```

2. Run the bridge deployment script:
```
forge script ./script/USDCBridgeDeploy.s.sol --private-key <YOUR_PRIVATE_KEY> --broadcast
```

3. Fill in both `.env` and `.env.<mainnet or testnet>` files with the following variables and push to repository if canonical deployment:
```
ETH_BRIDGE_PROXY_ADMIN=
ETH_BRIDGE_IMPLEMENTATION=
ETH_BRIDGE_PROXY=
CITREA_BRIDGE_PROXY_ADMIN=
CITREA_BRIDGE_IMPLEMENTATION=
CITREA_BRIDGE_PROXY=
```

## 3. Testing USDC Bridge
1. If not done already, copy the necessary .env file for the test script:
```
cp .env.<mainnet or testnet> .env
```

2. Test the deployment by running the test script which sends 1 cent from Ethereum to Citrea, you need to have some USDC on Ethereum for this:
```
forge script ./script/USDCBridgeMintTest.s.sol --private-key <YOUR_PRIVATE_KEY> --broadcast
```

3. If the script is successful, search for the `send` transaction (the other one is approval) in the output of the script on LayerZero Scan. Wait for the destination transaction hash, look it up on Citrea Explorer, and confirm that Citrea USDC was minted to the address associated with the private key used above.

4. Similarly, run the test script which sends 1 cent from Citrea to Ethereum, you need to have some bridged USDC on Citrea for this:

```
forge script ./script/USDCBridgeBurnTest.s.sol --private-key <YOUR_PRIVATE_KEY> --broadcast
```

5. If the script is successful, search for the `send` transaction (the other one is approval) in the output of the script on LayerZero Scan. Wait for the destination transaction hash, look it up on Ethereum Explorer, and confirm that USDC was burned from Citrea and 1 cent was sent to the address associated with the private key used above.

## 4. Upgrading the USDC Bridge for Circle takeover



