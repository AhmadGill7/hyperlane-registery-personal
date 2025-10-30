#!/bin/bash

# Run Relayer
# This relayer delivers messages between BSC Testnet and Kasplex Testnet

if [ -z "$HYP_KEY" ]; then
    echo "❌ Error: HYP_KEY environment variable is not set"
    echo "Please run: export HYP_KEY=\"your_private_key\""
    exit 1
fi

echo "🚀 Starting Relayer..."
echo "📍 Relayer Address: $(cast wallet address --private-key $HYP_KEY)"
echo "🔗 Relaying between: BSC Testnet ↔️ Kasplex Testnet"
echo ""

# Disable Git Bash path conversion
export MSYS_NO_PATHCONV=1

# Get the absolute Windows-style path for Docker on Windows
WORK_DIR="/d/hyperlane-registery-personal"

docker run -it --rm \
  --name relayer \
  -e CONFIG_FILES="/app/kasplextestnet-config.json" \
  -v "${WORK_DIR}/kasplextestnet-config.json:/app/kasplextestnet-config.json" \
  -v "${WORK_DIR}/hyperlane-db-relayer:/app/hyperlane-db-relayer" \
  -v "${WORK_DIR}/hyperlane-validator-signatures-bsctestnet:/app/hyperlane-validator-signatures-bsctestnet:ro" \
  -v "${WORK_DIR}/hyperlane-validator-signatures-kasplextestnet:/app/hyperlane-validator-signatures-kasplextestnet:ro" \
  -p 9092:9092 \
  gcr.io/abacus-labs-dev/hyperlane-agent:agents-v1.4.0 \
  ./relayer \
  --db /app/hyperlane-db-relayer \
  --relayChains bsctestnet,kasplextestnet \
  --chains.bsctestnet.signer.type hexKey \
  --chains.bsctestnet.signer.key ${HYP_KEY} \
  --chains.bsctestnet.customRpcUrls https://bsc-testnet.publicnode.com \
  --chains.kasplextestnet.signer.type hexKey \
  --chains.kasplextestnet.signer.key ${HYP_KEY} \
  --allowLocalCheckpointSyncers true \
  --defaultSigner.type hexKey \
  --defaultSigner.key ${HYP_KEY} \
  --metrics-port 9092
