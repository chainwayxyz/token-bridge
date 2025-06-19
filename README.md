If bridge is going to work with already deployed USDC on Citrea, skip to section 2.

## 1. Deploying USDC

1. Fill `./stablecoin-evm_env/.env.citrea-usdc` for the following variables:

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
cp ../bridged-usdc-citrea/stablecoin-evm_env/.env.citrea-usdc .env
echo "[]" > blacklist.remote.json
yarn forge:simulate scripts/deploy/deploy-fiat-token.s.sol --rpc-url <testnet OR mainnet>
yarn forge:broadcast scripts/deploy/deploy-fiat-token.s.sol --rpc-url <testnet OR mainnet>
yarn forge:verify scripts/deploy/deploy-fiat-token.s.sol --rpc-url <testnet OR mainnet>
```

// TODO: Add more detail.
3. Save the compilation output for verification.

## 2. Deploying USDC Bridge
1. Depending on the network, copy the necessary .env file:
```
cp .env.<mainnet or testnet> .env
```

2. If section 1 is skipped, skip this step. If new USDC is deployed, update the following variables with the new deployed addresses produced in section 1:
```
CITREA_USDC=<FIAT_TOKEN_PROXY_ADDRESS>
CITREA_MM=<MASTER_MINTER_ADDRESS>
```

3. Run the bridge deployment script:
```
forge script ./script/USDCBridgeDeploy.s.sol --private-key <YOUR_PRIVATE_KEY> --broadcast
```

4. Fill in both `.env` and `.env.<mainnet or testnet>` files with the following variables and push to repository if canonical deployment:
```
ETH_PROXY_ADMIN=
ETH_USDC_BRIDGE_IMPLEMENTATION=
ETH_USDC_BRIDGE_PROXY=
CITREA_PROXY_ADMIN=
CITREA_USDC_BRIDGE_IMPLEMENTATION=
CITREA_USDC_BRIDGE_PROXY=
```

## 3. Upgrading the USDC Bridge for Circle takeover



