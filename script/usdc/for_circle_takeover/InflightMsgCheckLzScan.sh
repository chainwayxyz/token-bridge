#!/bin/bash

set -euo pipefail

cd "$(git rev-parse --show-toplevel)"
source .env
CURRENT_DIR=$(pwd)

if [ "$NETWORK" = "mainnet" ]; then
    BASE_URL="https://scan.layerzero-api.com/v1"
elif [ "$NETWORK" = "testnet" ]; then
    BASE_URL="https://scan-testnet.layerzero-api.com/v1"
else
    echo "ERROR: NETWORK must be set to 'mainnet' or 'testnet'"
    exit 1
fi

CONFIG_FILE="$CURRENT_DIR/config/$NETWORK/config.toml"

DEST_EID=$(yq '.dest.lz.eid' "$CONFIG_FILE")
SRC_EID=$(yq '.src.lz.eid' "$CONFIG_FILE")
DEST_ADDRESS=$(yq '.dest.usdc.bridge.deployment.proxy' "$CONFIG_FILE")
SRC_ADDRESS=$(yq '.src.usdc.bridge.deployment.proxy' "$CONFIG_FILE")

# Function to check status for a given EID and address
check_status() {
    local eid=$1
    local address=$2
    local name=$3

    if ! response=$(curl -s "$BASE_URL/messages/oapp/$eid/$address" 2>&1); then
        echo "ERROR: Failed to fetch data from LayerZero Scan for $name."
        exit 1
    fi
    
    if ! inflight_messages=$(echo "$response" | jq -r '.data[]? | select(.status.name == "INFLIGHT" or .status.name == "CONFIRMING")' 2>&1); then
        echo "ERROR: Failed to parse response JSON for $name."
        exit 1
    fi
    
    if [ -n "$inflight_messages" ]; then
        echo "ERROR: There is an INFLIGHT or CONFIRMING message."
        exit 1
    else
        return 0
    fi
}

# Check both dest and src
check_status "$DEST_EID" "$DEST_ADDRESS" "DEST"
check_status "$SRC_EID" "$SRC_ADDRESS" "SRC"
echo "SUCCESS: All checks passed."