#!/bin/bash

# Run BSC Testnet Validator
# This validator watches the BSC Testnet mailbox and signs message roots

if [ -z "$HYP_KEY" ]; then
    echo "❌ Error: HYP_KEY environment variable is not set"
    echo "Please run: export HYP_KEY=\"your_private_key\""
    exit 1
fi

echo "🔐 Starting BSC Testnet Validator..."
echo "📍 Validator Address: $(cast wallet address --private-key $HYP_KEY)"
echo ""

# Disable Git Bash path conversion
export MSYS_NO_PATHCONV=1

# Get the absolute Windows-style path for Docker on Windows
WORK_DIR="/d/hyperlane-registery-personal"

docker run -it --rm \
  --name validator-bsc \
  -v "${WORK_DIR}/hyperlane-db-bsctestnet:/app/hyperlane-db-bsctestnet" \
  -v "${WORK_DIR}/hyperlane-validator-signatures-bsctestnet:/app/hyperlane-validator-signatures-bsctestnet" \
  -p 9090:9090 \
  gcr.io/abacus-labs-dev/hyperlane-agent:agents-v1.4.0 \
  ./validator \
  --db /app/hyperlane-db-bsctestnet \
  --originChainName bsctestnet \
  --validator.type hexKey \
  --validator.key ${HYP_KEY} \
  --chains.bsctestnet.signer.type hexKey \
  --chains.bsctestnet.signer.key ${HYP_KEY} \
  --chains.bsctestnet.customRpcUrls https://bsc-testnet.publicnode.com \
  --checkpointSyncer.type localStorage \
  --checkpointSyncer.path /app/hyperlane-validator-signatures-bsctestnet \
  --metrics-port 9090
