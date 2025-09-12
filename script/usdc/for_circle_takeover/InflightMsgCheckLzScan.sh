#!/bin/bash

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
    
    response=$(curl -s "$BASE_URL/messages/oapp/$eid/$address")
    if echo "$response" | jq -e '.data[] | select(.status.name == "INFLIGHT" or .status.name == "CONFIRMING")' > /dev/null; then
        return 1
    else
        return 0
    fi
}

# Check both dest and src
check_status "$DEST_EID" "$DEST_ADDRESS" "DEST"
dest_result=$?

check_status "$SRC_EID" "$SRC_ADDRESS" "SRC"
src_result=$?

# Exit successfully only if both checks passed
if [ $dest_result -eq 0 ] && [ $src_result -eq 0 ]; then
    echo "SUCCESS: All checks passed."
    exit 0
else
    echo "ERROR: There is an inflight message either at source or destination."
    exit 1
fi