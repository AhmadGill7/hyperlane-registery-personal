#!/bin/bash

# Hyperlane Validator & Relayer Setup Script
# This script helps you set up validators and relayer for BSC Testnet <-> Kasplex Testnet bridge

set -e

echo "================================================"
echo "🌉 Hyperlane Validator & Relayer Setup"
echo "================================================"
echo ""

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if HYP_KEY is set
if [ -z "$HYP_KEY" ]; then
    echo -e "${RED}❌ Error: HYP_KEY environment variable is not set${NC}"
    echo ""
    echo "Please set your private key:"
    echo "  export HYP_KEY=\"your_private_key_here\""
    echo ""
    exit 1
fi

echo -e "${GREEN}✅ HYP_KEY is set${NC}"

# Get the validator address
VALIDATOR_ADDRESS=$(cast wallet address --private-key $HYP_KEY 2>/dev/null || echo "")

if [ -z "$VALIDATOR_ADDRESS" ]; then
    echo -e "${RED}❌ Error: Could not derive address from HYP_KEY${NC}"
    echo "Make sure 'cast' is installed (from foundry)"
    exit 1
fi

echo -e "${GREEN}✅ Validator Address: ${VALIDATOR_ADDRESS}${NC}"
echo ""

# Check Docker
echo "Checking Docker installation..."
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed${NC}"
    echo ""
    echo "Please install Docker:"
    echo "  https://docs.docker.com/get-docker/"
    exit 1
fi

echo -e "${GREEN}✅ Docker is installed${NC}"
echo ""

# Pull Docker image
echo "================================================"
echo "📦 Pulling Hyperlane Agent Docker Image"
echo "================================================"
echo ""

docker pull --platform linux/amd64 gcr.io/abacus-labs-dev/hyperlane-agent:agents-v1.4.0

echo ""
echo -e "${GREEN}✅ Docker image pulled successfully${NC}"
echo ""

# Create directories for databases and signatures
echo "Creating directories..."
mkdir -p hyperlane-db-bsctestnet
mkdir -p hyperlane-db-kasplextestnet
mkdir -p hyperlane-db-relayer
mkdir -p hyperlane-validator-signatures-bsctestnet
mkdir -p hyperlane-validator-signatures-kasplextestnet

echo -e "${GREEN}✅ Directories created${NC}"
echo ""

# Update config files with the key
echo "Updating configuration files with your key..."

# Update validator-bsctestnet.json
jq --arg key "$HYP_KEY" \
   '.chains.bsctestnet.signer.key = $key | .validator.key = $key' \
   configs/validator-bsctestnet.json > configs/validator-bsctestnet.json.tmp
mv configs/validator-bsctestnet.json.tmp configs/validator-bsctestnet.json

# Update validator-kasplextestnet.json
jq --arg key "$HYP_KEY" \
   '.chains.kasplextestnet.signer.key = $key | .validator.key = $key' \
   configs/validator-kasplextestnet.json > configs/validator-kasplextestnet.json.tmp
mv configs/validator-kasplextestnet.json.tmp configs/validator-kasplextestnet.json

# Update relayer-config.json
jq --arg key "$HYP_KEY" \
   '.chains.bsctestnet.signer.key = $key | .chains.kasplextestnet.signer.key = $key' \
   configs/relayer-config.json > configs/relayer-config.json.tmp
mv configs/relayer-config.json.tmp configs/relayer-config.json

echo -e "${GREEN}✅ Configuration files updated${NC}"
echo ""

# Check balances
echo "================================================"
echo "💰 Checking Balances"
echo "================================================"
echo ""

echo "Validator/Relayer Address: ${VALIDATOR_ADDRESS}"
echo ""

echo -n "BSC Testnet balance: "
BSC_BALANCE=$(cast balance ${VALIDATOR_ADDRESS} --rpc-url https://bsc-testnet.publicnode.com 2>/dev/null || echo "0")
echo "${BSC_BALANCE} wei ($(cast --from-wei ${BSC_BALANCE} 2>/dev/null || echo '0') BNB)"

echo -n "Kasplex Testnet balance: "
KASPLEX_BALANCE=$(cast balance ${VALIDATOR_ADDRESS} --rpc-url https://rpc.kasplextest.xyz 2>/dev/null || echo "0")
echo "${KASPLEX_BALANCE} wei ($(cast --from-wei ${KASPLEX_BALANCE} 2>/dev/null || echo '0') KAS)"
echo ""

# Check if sufficient funds
BSC_SUFFICIENT=false
KASPLEX_SUFFICIENT=false

if [ "$BSC_BALANCE" -gt "1000000000000000" ]; then  # > 0.001 BNB
    BSC_SUFFICIENT=true
fi

if [ "$KASPLEX_BALANCE" -gt "100000000000000000" ]; then  # > 0.1 KAS
    KASPLEX_SUFFICIENT=true
fi

if [ "$BSC_SUFFICIENT" = true ] && [ "$KASPLEX_SUFFICIENT" = true ]; then
    echo -e "${GREEN}✅ Sufficient funds on both chains${NC}"
else
    echo -e "${YELLOW}⚠️  Warning: Insufficient funds${NC}"
    echo ""
    echo "Required minimum balances:"
    echo "  - BSC Testnet: 0.001 BNB (for validator announcement)"
    echo "  - Kasplex Testnet: 0.1 KAS (for validator announcement)"
    echo ""
    echo "Recommended for relayer:"
    echo "  - BSC Testnet: 0.1 BNB"
    echo "  - Kasplex Testnet: 10 KAS"
    echo ""
fi

echo "================================================"
echo "📋 Next Steps"
echo "================================================"
echo ""
echo "To start the validators and relayer, run these commands in separate terminals:"
echo ""
echo -e "${YELLOW}Terminal 1 - BSC Testnet Validator:${NC}"
echo "./run-validator-bsc.sh"
echo ""
echo -e "${YELLOW}Terminal 2 - Kasplex Testnet Validator:${NC}"
echo "./run-validator-kasplex.sh"
echo ""
echo -e "${YELLOW}Terminal 3 - Relayer:${NC}"
echo "./run-relayer.sh"
echo ""
echo "Creating these scripts now..."
echo ""

# Create run scripts
cat > run-validator-bsc.sh << 'EOFBSC'
#!/bin/bash
docker run -it --rm \
  --name validator-bsc \
  -v "$(pwd)/hyperlane-db-bsctestnet:/hyperlane-db-bsctestnet" \
  -v "$(pwd)/hyperlane-validator-signatures-bsctestnet:/hyperlane-validator-signatures-bsctestnet" \
  -p 9090:9090 \
  gcr.io/abacus-labs-dev/hyperlane-agent:agents-v1.4.0 \
  ./validator \
  --db /hyperlane-db-bsctestnet \
  --originChainName bsctestnet \
  --validator.type hexKey \
  --validator.key ${HYP_KEY} \
  --chains.bsctestnet.signer.type hexKey \
  --chains.bsctestnet.signer.key ${HYP_KEY} \
  --chains.bsctestnet.customRpcUrls https://bsc-testnet.publicnode.com \
  --checkpointSyncer.type localStorage \
  --checkpointSyncer.path /hyperlane-validator-signatures-bsctestnet \
  --metrics-port 9090
EOFBSC

cat > run-validator-kasplex.sh << 'EOFKASPLEX'
#!/bin/bash
docker run -it --rm \
  --name validator-kasplex \
  -v "$(pwd)/hyperlane-db-kasplextestnet:/hyperlane-db-kasplextestnet" \
  -v "$(pwd)/hyperlane-validator-signatures-kasplextestnet:/hyperlane-validator-signatures-kasplextestnet" \
  -p 9091:9091 \
  gcr.io/abacus-labs-dev/hyperlane-agent:agents-v1.4.0 \
  ./validator \
  --db /hyperlane-db-kasplextestnet \
  --originChainName kasplextestnet \
  --validator.type hexKey \
  --validator.key ${HYP_KEY} \
  --chains.kasplextestnet.signer.type hexKey \
  --chains.kasplextestnet.signer.key ${HYP_KEY} \
  --chains.kasplextestnet.customRpcUrls https://rpc.kasplextest.xyz \
  --checkpointSyncer.type localStorage \
  --checkpointSyncer.path /hyperlane-validator-signatures-kasplextestnet \
  --metrics-port 9091
EOFKASPLEX

cat > run-relayer.sh << 'EOFRELAYER'
#!/bin/bash
docker run -it --rm \
  --name relayer \
  -v "$(pwd)/hyperlane-db-relayer:/hyperlane-db-relayer" \
  -v "$(pwd)/hyperlane-validator-signatures-bsctestnet:/hyperlane-validator-signatures-bsctestnet:ro" \
  -v "$(pwd)/hyperlane-validator-signatures-kasplextestnet:/hyperlane-validator-signatures-kasplextestnet:ro" \
  -p 9092:9092 \
  gcr.io/abacus-labs-dev/hyperlane-agent:agents-v1.4.0 \
  ./relayer \
  --db /hyperlane-db-relayer \
  --relayChains bsctestnet,kasplextestnet \
  --chains.bsctestnet.signer.type hexKey \
  --chains.bsctestnet.signer.key ${HYP_KEY} \
  --chains.bsctestnet.customRpcUrls https://bsc-testnet.publicnode.com \
  --chains.kasplextestnet.signer.type hexKey \
  --chains.kasplextestnet.signer.key ${HYP_KEY} \
  --chains.kasplextestnet.customRpcUrls https://rpc.kasplextest.xyz \
  --allowLocalCheckpointSyncers true \
  --metrics-port 9092
EOFRELAYER

chmod +x run-validator-bsc.sh
chmod +x run-validator-kasplex.sh
chmod +x run-relayer.sh

echo -e "${GREEN}✅ Run scripts created and made executable${NC}"
echo ""
echo "================================================"
echo "🎉 Setup Complete!"
echo "================================================"
echo ""
echo "Your validator address: ${VALIDATOR_ADDRESS}"
echo ""
echo "Ready to start! Open 3 terminals and run:"
echo "  1. ./run-validator-bsc.sh"
echo "  2. ./run-validator-kasplex.sh"
echo "  3. ./run-relayer.sh"
echo ""
