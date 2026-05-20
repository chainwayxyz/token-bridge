#!/bin/bash
# Decodes LayerZero setConfig(address,address,(uint32,uint32,bytes)[]) calldata
# Usage: ./decode_lz_setconfig.sh <calldata>

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <calldata>"
    echo "Example: $0 0x6dbd9f90..."
    exit 1
fi

DATA="$1"

echo "=== Decoded setConfig(address,address,(uint32,uint32,bytes)[]) ==="
echo ""

# Decode outer call
DECODED=$(cast calldata-decode "setConfig(address,address,(uint32,uint32,bytes)[])" "$DATA")
OAPP=$(echo "$DECODED" | sed -n '1p')
MSGLIB=$(echo "$DECODED" | sed -n '2p')

echo "OApp:   $OAPP"
echo "MsgLib: $MSGLIB"
echo ""

# Extract config bytes (the long hex string) - macOS compatible
CONFIG_HEX=$(echo "$DECODED" | grep -Eo '0x[0-9a-fA-F]{100,}' | head -1)
HEX=${CONFIG_HEX#0x}

# Extract eid and configType
EID=$(echo "$DECODED" | grep -Eo '\([0-9]+' | head -1 | tr -d '(')
CONFIG_TYPE=$(echo "$DECODED" | grep -Eo ', [0-9]+,' | head -1 | sed 's/[, ]//g')

echo "SetConfigParam[0]:"
echo "  eid:        $EID"

if [ "$CONFIG_TYPE" == "2" ]; then
    echo "  configType: 2 (UlnConfig)"
    echo ""
    echo "  UlnConfig:"

    # Parse UlnConfig struct (skip first 32 bytes which is offset pointer)
    CONFIRMATIONS=$((16#${HEX:64:64}))
    REQUIRED_DVN_COUNT=$((16#${HEX:128:64}))
    OPTIONAL_DVN_COUNT=$((16#${HEX:192:64}))
    OPTIONAL_DVN_THRESHOLD=$((16#${HEX:256:64}))

    echo "    confirmations:        $CONFIRMATIONS"
    echo "    requiredDVNCount:     $REQUIRED_DVN_COUNT"
    echo "    optionalDVNCount:     $OPTIONAL_DVN_COUNT"
    echo "    optionalDVNThreshold: $OPTIONAL_DVN_THRESHOLD"

    echo "    requiredDVNs:"
    for i in $(seq 0 $((REQUIRED_DVN_COUNT - 1))); do
        OFFSET=$((536 + i * 64))
        ADDR="0x${HEX:$OFFSET:40}"
        echo "      [$i]: $ADDR"
    done

    echo "    optionalDVNs:"
    OPTIONAL_START=$((536 + REQUIRED_DVN_COUNT * 64 + 64))
    for i in $(seq 0 $((OPTIONAL_DVN_COUNT - 1))); do
        OFFSET=$((OPTIONAL_START + i * 64))
        ADDR="0x${HEX:$OFFSET:40}"
        echo "      [$i]: $ADDR"
    done

elif [ "$CONFIG_TYPE" == "1" ]; then
    echo "  configType: 1 (ExecutorConfig)"
    echo ""
    echo "  ExecutorConfig:"

    MAX_MSG_SIZE=$((16#${HEX:0:64}))
    EXECUTOR="0x${HEX:88:40}"

    echo "    maxMessageSize: $MAX_MSG_SIZE"
    echo "    executor:       $EXECUTOR"
else
    echo "  configType: $CONFIG_TYPE (Unknown)"
    echo "  rawConfig:  $CONFIG_HEX"
fi
