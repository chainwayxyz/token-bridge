#!/bin/bash

# Logic is taken from the deployment section of the README of `https://github.com/circlefin/stablecoin-evm`
# This script deploys the USDC contracts with the values from config.

cd "$(git rev-parse --show-toplevel)"
source .env
# Run foundryup to ensure keystore works
foundryup
CURRENT_DIR=$(pwd)

if [[ "$NETWORK" != "mainnet" && "$NETWORK" != "testnet" ]]; then
    echo "Error: NETWORK must be either 'mainnet' or 'testnet'."
    exit 1
fi

CONFIG_PATH="$CURRENT_DIR/config/${NETWORK}/config.toml"

DEPLOYER_ADDRESS=$(cast wallet address --account ${ACCOUNT_NAME} --password ${PASSWORD})
export DEPLOYER_PRIVATE_KEY=$(cast wallet decrypt-keystore ${ACCOUNT_NAME} --unsafe-password ${PASSWORD} | awk -F': ' '{print $2}')
export TOKEN_NAME=$(yq '.dest.usdc.init.name' $CONFIG_PATH)
export TOKEN_SYMBOL=$(yq '.dest.usdc.init.symbol' $CONFIG_PATH)
export TOKEN_CURRENCY="USD"
export TOKEN_DECIMALS=6
export PROXY_ADMIN_ADDRESS=$(yq '.dest.usdc.init.proxyAdmin' $CONFIG_PATH)
export OWNER_ADDRESS=$(yq '.dest.usdc.init.owner' $CONFIG_PATH)
# Initially set the master minter owner to the deployer address, it will be updated later in `06_USDCAndBridgeAssignRoles.s.sol`
export MASTER_MINTER_OWNER_ADDRESS=$DEPLOYER_ADDRESS
export GAS_MULTIPLIER=110
export BLACKLIST_FILE_NAME=blacklist.remote.json
RPC_URL=$(yq '.dest.rpc' $CONFIG_PATH)

# Assert PROXY_ADMIN_ADDRESS is not equal to DEPLOYER_ADDRESS
if [ "$PROXY_ADMIN_ADDRESS" == "$DEPLOYER_ADDRESS" ]; then
    echo "Error: USDC Proxy Admin cannot be the same as deployer address."
    exit 1
fi
git clone https://github.com/circlefin/stablecoin-evm.git
cd stablecoin-evm
git checkout c8c31b2
echo "[]" > blacklist.remote.json
yarn install
# Proceed with the deployment
logs=$(yarn forge:broadcast scripts/deploy/deploy-fiat-token.s.sol --rpc-url $RPC_URL --json | sed -n '/^{"logs":/p')
DEST_MM=$(jq -r '.returns."1".value' <<< "$logs")
DEST_USDC_PROXY=$(jq -r '.returns."2".value' <<< "$logs")
echo "Destination MasterMinter: $DEST_MM"
echo "Destination USDC Proxy: $DEST_USDC_PROXY"

VENV_NAME=".deploy_venv"
# Create venv if it doesn't exist
if [ ! -d "$VENV_NAME" ]; then
    python3 -m venv $VENV_NAME
fi

# Activate virtual environment
source $VENV_NAME/bin/activate
# Upgrade pip and install required packages
python3 -m pip install --upgrade pip
python3 -m pip install tomli tomli-w

# Update the config file with the new addresses, have to use python as yq does not support TOML outputs
python3 -c "
import tomli
import tomli_w

# Read the TOML file
with open('$CONFIG_PATH', 'rb') as f:
    config = tomli.load(f)

# Update the config with new addresses
config['dest']['usdc']['deployment']['masterMinter'] = '$DEST_MM'
config['dest']['usdc']['deployment']['proxy'] = '$DEST_USDC_PROXY'

# Write back to TOML file
with open('$CONFIG_PATH', 'wb') as f:
    tomli_w.dump(config, f)

print('Config file updated successfully')
"

# Deactivate virtual environment
deactivate

# Above commands downgrades foundry to 0.2.0, so we need to run foundryup again
foundryup
