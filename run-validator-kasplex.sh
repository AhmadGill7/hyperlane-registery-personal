#!/bin/bash

# Run Kasplex Testnet Validator
# This validator watches the Kasplex Testnet mailbox and signs message roots

if [ -z "$HYP_KEY" ]; then
    echo "❌ Error: HYP_KEY environment variable is not set"
    echo "Please run: export HYP_KEY=\"your_private_key\""
    exit 1
fi

echo "🔐 Starting Kasplex Testnet Validator..."
echo "📍 Validator Address: $(cast wallet address --private-key $HYP_KEY)"
echo ""

# Disable Git Bash path conversion
export MSYS_NO_PATHCONV=1

# Get the absolute Windows-style path for Docker on Windows
WORK_DIR="/d/hyperlane-registery-personal"

docker run -it --rm \
  --name validator-kasplex \
  -e CONFIG_FILES="/app/kasplextestnet-config.json" \
  -v "${WORK_DIR}/kasplextestnet-config.json:/app/kasplextestnet-config.json" \
  -v "${WORK_DIR}/hyperlane-db-kasplextestnet:/app/hyperlane-db-kasplextestnet" \
  -v "${WORK_DIR}/hyperlane-validator-signatures-kasplextestnet:/app/hyperlane-validator-signatures-kasplextestnet" \
  -p 9091:9091 \
  gcr.io/abacus-labs-dev/hyperlane-agent:agents-v1.4.0 \
  ./validator \
  --db /app/hyperlane-db-kasplextestnet \
  --originChainName kasplextestnet \
  --validator.type hexKey \
  --validator.key ${HYP_KEY} \
  --chains.kasplextestnet.signer.type hexKey \
  --chains.kasplextestnet.signer.key ${HYP_KEY} \
  --checkpointSyncer.type localStorage \
  --checkpointSyncer.path /app/hyperlane-validator-signatures-kasplextestnet \
  --checkpointSyncer.period 300 \
  --reorgPeriod 1 \
  --interval 5 \
  --metrics-port 9091
